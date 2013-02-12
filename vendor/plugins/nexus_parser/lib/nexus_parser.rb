require File.expand_path(File.join(File.dirname(__FILE__), 'nexus_parser', 'tokens'))
require File.expand_path(File.join(File.dirname(__FILE__), 'nexus_parser', 'lexer'))
require File.expand_path(File.join(File.dirname(__FILE__), 'nexus_parser', 'output'))
require File.expand_path(File.join(File.dirname(__FILE__), 'nexus_parser', 'output_builder'))

class NexusParser
  ParseError = Class.new(StandardError)

  class << self
    def parse_text(contents)
      contents.gsub!(/\[[^\]]*\]/,'')  # strip out all comments BEFORE we parse the file
      parser = self.new(NexusParser::Lexer.new(contents), builder = NexusParser::OutputBuilder.new)
      parser.parse_contents
      builder.nexus_file
    end
  end

  def initialize(lexer, builder)
    @lexer = lexer
    @builder = builder
  end

  def parse_contents
    puts "*** start parsing file ***"
    @lexer.pop(NexusParser::Tokens::NexusStart)
    while @lexer.peek(it=NexusParser::Tokens::BeginBlk)
      @lexer.pop(it)
      if @lexer.peek(NexusParser::Tokens::AuthorsBlk)       then parse_authors_blk
      elsif @lexer.peek(NexusParser::Tokens::TaxaBlk)       then parse_taxa_blk
      elsif @lexer.peek(NexusParser::Tokens::ChrsBlk)       then parse_characters_blk
      elsif @lexer.peek(NexusParser::Tokens::NotesBlk)      then parse_notes_blk
      elsif @lexer.peek(NexusParser::Tokens::DataBlk)       then parse_data_blk
      elsif @lexer.peek(it=NexusParser::Tokens::GenericBlk) then @lexer.pop(it)
      end
    end
    puts "*** end parsing file ***"
  end

  # just removes it for the time being
  def parse_authors_blk
    # thing has non single word key/value pairs, like "AUTHOR NAME", SIGH
    # for now just slurp it all up.
    @lexer.pop(NexusParser::Tokens::AuthorsBlk )
  end

  def parse_taxa_blk
    puts "*** start parsing taxa block ***"
    @lexer.pop(NexusParser::Tokens::TaxaBlk)
    @lexer.pop(NexusParser::Tokens::Title) if @lexer.peek(NexusParser::Tokens::Title)

    parse_dimensions if @lexer.peek(NexusParser::Tokens::Dimensions)

    until @lexer.peek(NexusParser::Tokens::EndBlk)
      if @lexer.peek(NexusParser::Tokens::Taxlabels)
        @lexer.pop(NexusParser::Tokens::Taxlabels) if @lexer.peek(NexusParser::Tokens::Taxlabels)
        i = 0
        while @lexer.peek(NexusParser::Tokens::Label)
          taxon_name = @lexer.pop(NexusParser::Tokens::Label).value.gsub(/_/, " ").strip
          @builder.taxa[i] = NexusParser::Output::Taxon.new(i+1, taxon_name)
          i += 1
        end
        @lexer.pop(NexusParser::Tokens::SemiColon) if @lexer.peek(NexusParser::Tokens::SemiColon) # close of tax labels, placement of this seems dubious... but tests are working
      elsif  @lexer.peek(NexusParser::Tokens::MesquiteIDs)
        @lexer.pop(NexusParser::Tokens::MesquiteIDs) # trashing these for now
      elsif  @lexer.peek(NexusParser::Tokens::MesquiteBlockID)
        @lexer.pop(NexusParser::Tokens::MesquiteBlockID)
      end
    end
    @lexer.pop(NexusParser::Tokens::EndBlk)
    puts "*** end parsing taxa block ***"
  end

  def parse_characters_blk
    puts "*** start parsing characters block ***"
    @lexer.pop(NexusParser::Tokens::ChrsBlk)
    until @lexer.peek(NexusParser::Tokens::EndBlk)
      if @lexer.peek(it=NexusParser::Tokens::Title)              then @lexer.pop(it)
      elsif @lexer.peek(NexusParser::Tokens::Dimensions)         then parse_dimensions
      elsif @lexer.peek(NexusParser::Tokens::Format)             then parse_format
      elsif @lexer.peek(NexusParser::Tokens::CharLabels)         then parse_chr_labels
      elsif @lexer.peek(NexusParser::Tokens::StateLabels)        then parse_state_labels
      elsif @lexer.peek(NexusParser::Tokens::CharStateLabels)    then parse_chr_state_labels
      elsif @lexer.peek(NexusParser::Tokens::Matrix)             then parse_matrix
      elsif @lexer.peek(it=NexusParser::Tokens::MesquiteIDs)     then @lexer.pop(it) # trashing these for now
      elsif @lexer.peek(it=NexusParser::Tokens::MesquiteBlockID) then @lexer.pop(it)
      end# trashing these for now
    end
    @lexer.pop(NexusParser::Tokens::EndBlk)
    puts "*** end parsing characters block ***"
  end

  # added by ChrisG
  def parse_data_blk
    puts "*** start parsing data block ***"
    @lexer.pop(NexusParser::Tokens::DataBlk)
    until @lexer.peek(NexusParser::Tokens::EndBlk)
      if @lexer.peek(NexusParser::Tokens::CharStateLabels)
        parse_chr_state_labels
      elsif @lexer.peek(NexusParser::Tokens::Dimensions)
        parse_dimensions
      elsif @lexer.peek(NexusParser::Tokens::Format)
        parse_format
      elsif @lexer.peek(NexusParser::Tokens::Options)
        parse_options
      elsif @lexer.peek(NexusParser::Tokens::CharLabels)
        parse_chr_labels
      elsif @lexer.peek(NexusParser::Tokens::StateLabels)
        parse_state_labels
      elsif @lexer.peek(NexusParser::Tokens::Matrix)
        parse_matrix
      end
    end
    puts "*** end parsing data block ***"
  end

  # prolly pop header then fuse with parse_dimensions
  def parse_format
    @lexer.pop(NexusParser::Tokens::Format)
    while @lexer.peek(NexusParser::Tokens::ValuePair)
      @builder.add_var(@lexer.pop(NexusParser::Tokens::ValuePair).value)
    end
  end

  def parse_options
    @lexer.pop(NexusParser::Tokens::Options)
    while @lexer.peek(NexusParser::Tokens::ValuePair)
      @builder.add_var(@lexer.pop(NexusParser::Tokens::ValuePair).value)
    end
  end

  def parse_dimensions
    @lexer.pop(NexusParser::Tokens::Dimensions)
    while @lexer.peek(NexusParser::Tokens::ValuePair)
      @builder.add_var(@lexer.pop(NexusParser::Tokens::ValuePair).value)
    end
  end

  def parse_chr_state_labels
    puts "*** start parsing chr state labels ***"
    @lexer.pop(NexusParser::Tokens::CharStateLabels)

    until @lexer.peek(NexusParser::Tokens::SemiColon)
      character_index = @lexer.pop(NexusParser::Tokens::Number).value
      character_name = @lexer.peek(NexusParser::Tokens::Label) ?
        @lexer.pop(NexusParser::Tokens::Label).value.gsub(/_/, " ").strip.capitalize :
        ""
      character = NexusParser::Output::Character.new(character_index, character_name)

      @lexer.pop(NexusParser::Tokens::BckSlash) if @lexer.peek(NexusParser::Tokens::BckSlash)

      i = -1
      while @lexer.peek(NexusParser::Tokens::Label)
        state_name = @lexer.pop(NexusParser::Tokens::Label).value.gsub(/_/, " ").strip
        character.states[i+=1] = NexusParser::Output::ChrState.new(state_name)
      end
      @lexer.pop(NexusParser::Tokens::Comma) if @lexer.peek(NexusParser::Tokens::Comma) # we may also have hit semicolon
      @builder.characters[character.index-1] = character
    end
    @lexer.pop(NexusParser::Tokens::SemiColon)
    puts "*** end parsing chr state labels ***"
  end

  def parse_chr_labels
    puts "*** start parsing chr labels ***"
    @lexer.pop(NexusParser::Tokens::CharLabels)
    until @lexer.peek(NexusParser::Tokens::SemiColon)
      character_index = (i=i.try(:+,1)||1)
      character_name = @lexer.pop(NexusParser::Tokens::Label).value.gsub(/_/, " ").strip.capitalize
      character = NexusParser::Output::Character.new(character_index, character_name)
      @builder.characters[character.index-1] = character
    end
    @lexer.pop(NexusParser::Tokens::SemiColon)
    puts "*** end parsing chr labels ***"
  end

  def parse_state_labels
    puts "*** start parsing state labels ***"
    @lexer.pop(NexusParser::Tokens::StateLabels)
    until @lexer.peek(NexusParser::Tokens::SemiColon)
      chr_index = @lexer.pop(NexusParser::Tokens::Number).value
      character = @builder.characters[chr_index-1]
      i = -1
      while @lexer.peek(NexusParser::Tokens::Label)
        state_name = @lexer.pop(NexusParser::Tokens::Label).value.gsub(/_/, " ").strip
        character.states[i+=1] = NexusParser::Output::ChrState.new(state_name)
      end
      @lexer.pop(NexusParser::Tokens::Comma) if @lexer.peek(NexusParser::Tokens::Comma)# we may also have hit semicolon
    end
    @lexer.pop(NexusParser::Tokens::SemiColon)
    puts "*** end parsing state labels ***"
  end

  def parse_matrix
    puts "*** start parsing matrix ***"
    @start_time = Time.now
    @lexer.pop(NexusParser::Tokens::Matrix)
    i = 0
    until @lexer.peek(NexusParser::Tokens::SemiColon)
      name = @lexer.pop(NexusParser::Tokens::Label).value.gsub(/_/, " ").strip
      @builder.taxa[i] = NexusParser::Output::Taxon.new(i+1, name) unless @builder.taxa[i] # if it exists its not re-added
      @builder.code_row(i, @lexer.pop(NexusParser::Tokens::RowVec).value)
      i += 1
    end
    @lexer.pop(NexusParser::Tokens::SemiColon) # pop the semicolon
    @end_time = Time.now
    puts "*** end parsing matrix ***"
    puts "parse matrix elapsed time: " + (@end_time - @start_time).to_s
  end

  # THIS SECTION IS PROBLEMATIC - COMMENTED OUT FOR NOW
  def parse_notes_blk
    puts "*** start parsing notes block ***"
    @lexer.pop(NexusParser::Tokens::NotesBlk)
#    # IMPORTANT - we don't parse the (CM <note>), we just strip the "(CM" ... ")" bit for now in Output::Note
#
#    @vars = {}
#    inf = 0
#    while true
#      inf += 1
#      raise "Either you have a gazillion notes or more likely parser is caught in an infinite loop inside parse_notes_block" if inf > 100000
#      if @lexer.peek(NexusParser::Tokens::EndBlk)
#        @lexer.pop(NexusParser::Tokens::EndBlk)
#        @builder.add_note(@vars) # one still left to add
#        break
#      else
#
#        if @lexer.peek(NexusParser::Tokens::ValuePair)
#          @vars.update(@lexer.pop(NexusParser::Tokens::ValuePair).value)
#
#        elsif @lexer.peek(NexusParser::Tokens::Label)
#          if @vars[:type] # we have the data for this row write it, and start a new one
#
#            @builder.add_note(@vars)
#            @vars = {}
#          else
#            @vars.update(:type => @lexer.pop(NexusParser::Tokens::Label).value)
#          end
#        elsif @lexer.peek(NexusParser::Tokens::FileLbl)
#          @lexer.pop(NexusParser::Tokens::FileLbl)
#          @vars.update(:file => 'file') # we check for whether :file key is present and handle conditionally
#        end
#      end
#    end
    puts "*** end parsing notes block ***"
  end
end
