class NexusParser::OutputBuilder # TreeBuilder

  # intermediate b/w Output and Parser

  # methods to build the
  def initialize
    @nf =  NexusParser::Output.new
  end

  def code_row(taxon_index, rowvector)

    @nf.characters.each_with_index do |c, i|
      @nf.codings[taxon_index.to_i] ||= []
      @nf.codings[taxon_index.to_i][i] = NexusParser::Output::Coding.new(:states => rowvector[i])

#      # !! we must update states for a given character if the state isn't found (not all states are referenced in description !!
#
#      existing_states = @nf.characters[i].state_labels
#
#      new_states = [*rowvector[i]]
#      new_states.delete("?") # we don't add this to the db
#      new_states = new_states - existing_states
#
#      new_states.each do |s|
#        @nf.characters[i].add_state(:label => s.to_i)
#      end

    end
  end

  def add_var(hash)
    hash.keys.each do |k|
      raise "var #{k} has already been set" if @nf.vars[:k]
    end
    @nf.vars.update(hash)
    if(@nf.vars[:nchar] && characters.size.zero?)
      stub_characters
    end
  end

  #  def update_taxon(index, name)
  #    taxa[index] = { :index => index, :name => name }
  #  end
  #
  #  # legal hash keys are :index, :name, and integers that point to state labels
  #  def update_chr(options = {} )
  #    @opt = {
  #      :name => ''
  #    }.merge!(options)
  #    return false if !@opt[:index]
  #
  #    @index = @opt[:index].to_i
  #
  #    # need to create the characters
  #
  #    raise(ParseError, "Can't update character of index #{@index}, it doesn't exist! This is a problem parsing the character state labels. Check the indices. It may be for this character \"#{@opt[:name]}\".") if !@nf.characters[@index]
  #
  #    (@nf.characters[@index].name = @opt[:name]) unless @opt[:name].empty?
  #
  #    @opt.delete(:index)
  #    @opt.delete(:name)
  #
  #    # the rest have states
  #    @opt.keys.each do |k|
  #
  #      if (@nf.characters[@index].states != {}) && @nf.characters[@index].states[k] # state exists
  #
  #        ## !! ONLY HANDLES NAME, UPDATE TO HANDLE notes etc. when we get them ##
  #        update_state(@index, :index => k, :name => @opt[k])
  #
  #      else # doesn't, create it
  #        @nf.characters[@index].add_state(:label => k.to_s, :name => @opt[k])
  #      end
  #    end
  #  end

  #  def update_state(chr_index, options = {})
  #    # only handling name now
  #    #options.keys.each do |k|
  #    @nf.characters[chr_index].states[options[:index]].name = options[:name]
  #    # add notes here
  #    # end
  #  end

  def add_note(options = {})
    @opt = {
      :text => ''
    }.merge!(options)

    case @opt[:type]

      # Why does mesquite differentiate b/w footnotes and annotations?!, apparently same data structure?
    when 'TEXT' # a footnote
      if @opt[:file]
        @nf.notes << NexusParser::Output::Note.new(@opt)

      elsif  @opt[:taxon] && @opt[:character] # its a cell, parse this case
        @nf.codings[@opt[:taxon].to_i - 1][@opt[:character].to_i - 1].notes = [] if !@nf.codings[@opt[:taxon].to_i - 1][@opt[:character].to_i - 1].notes
        @nf.codings[@opt[:taxon].to_i - 1][@opt[:character].to_i - 1].notes << NexusParser::Output::Note.new(@opt)

      elsif @opt[:taxon] && !@opt[:character]
        @nf.taxa[@opt[:taxon].to_i - 1].notes << NexusParser::Output::Note.new(@opt)

      elsif @opt[:character] && !@opt[:taxon]

        @nf.characters[@opt[:character].to_i - 1].notes << NexusParser::Output::Note.new(@opt)
      end

    when 'AN' # an annotation, rather than a footnote, same dif
      if @opt[:t] && @opt[:c]
        @nf.codings[@opt[:t].to_i - 1][@opt[:c].to_i - 1].notes = [] if !@nf.codings[@opt[:t].to_i - 1][@opt[:c].to_i - 1].notes
        @nf.codings[@opt[:t].to_i - 1][@opt[:c].to_i - 1].notes << NexusParser::Output::Note.new(@opt)
      elsif @opt[:t]
        @nf.taxa[@opt[:t].to_i - 1].notes << NexusParser::Output::Note.new(@opt)
      elsif @opt[:c]
        @nf.characters[@opt[:c].to_i - 1].notes << NexusParser::Output::Note.new(@opt)
      end
    end

  end

  def nexus_file
    @nf
  end

  def taxa
    @nf.taxa
  end

  def stub_characters
    chr_count = @nf.vars[:nchar].to_i
    @nf.characters = Array.new(chr_count) { |i| NexusParser::Output::Character.new(i+1, '') }
  end

  def characters
    @nf.characters
  end
end