class Parser

  def initialize(lexer, builder)
    @lexer = lexer
    @builder = builder
  end

  def parse_file
    # nf = @builder.new_nexus_file # create new local NexusFile instance, nf
    blks = []

    @lexer.pop(Tokens::NexusStart)

    while @lexer.peek(Tokens::BeginBlk)
       
      @lexer.pop(Tokens::BeginBlk) # pop it
      
      if @lexer.peek(Tokens::AuthorsBlk)
        parse_authors_blk

        
      # we parse these  
      elsif @lexer.peek(Tokens::TaxaBlk)
        @lexer.pop(Tokens::TaxaBlk )
        parse_taxa_blk
           
      elsif @lexer.peek(Tokens::ChrsBlk)
        @lexer.pop(Tokens::ChrsBlk)
        parse_characters_blk

      elsif @lexer.peek(Tokens::NotesBlk)
        @lexer.pop(Tokens::NotesBlk)  
        parse_notes_blk

        #added by ChrisG
      elsif @lexer.peek(Tokens::DataBlk)
        @lexer.pop(Tokens::DataBlk)
        parse_data_blk

      # we should parse this
      elsif @lexer.peek(Tokens::SetsBlk)
        @lexer.pop(Tokens::SetsBlk)

      # we don't parse these 
      elsif @lexer.peek(Tokens::TreesBlk)
        @foo =  @lexer.pop(Tokens::TreesBlk).value
 
      elsif @lexer.peek(Tokens::LabelsBlk)
        @lexer.pop(Tokens::LabelsBlk)
   
      elsif @lexer.peek(Tokens::MqCharModelsBlk)
        @lexer.pop(Tokens::MqCharModelsBlk) 

      elsif @lexer.peek(Tokens::AssumptionsBlk)
        @lexer.pop(Tokens::AssumptionsBlk)

      elsif @lexer.peek(Tokens::CodonsBlk)
        @lexer.pop(Tokens::CodonsBlk)
      end
      
    end
  end

  # just removes it for the time being
  def parse_authors_blk
    # thing has non single word key/value pairs, like "AUTHOR NAME", SIGH
    # for now just slurp it all up.
    @lexer.pop(Tokens::AuthorsBlk )

    #while true
    #  if @lexer.peek(Tokens::EndBlk)
    #    @lexer.pop(Tokens::EndBlk)
    #    break
    #  else

     #   while @lexer.peek(Tokens::ValuePair)
     #     # IMPORTANT, these are going to a general hash, there may ultimately be overlap of keys used in different blocks, this is ignored at present
     #     @builder.add_var(@lexer.pop(Tokens::ValuePair).value) 
     #   end
        
        #@lexer.pop(Tokens::ID) if @lexer.peek(Tokens::ID)
     # end
    #end
  end

  def parse_taxa_blk 
    @lexer.pop(Tokens::Title) if @lexer.peek(Tokens::Title)

    parse_dimensions if @lexer.peek(Tokens::Dimensions)

    while true
      if @lexer.peek(Tokens::EndBlk)
        @lexer.pop(Tokens::EndBlk)
        break
      else

        if @lexer.peek(Tokens::Taxlabels)
          @lexer.pop(Tokens::Taxlabels) if @lexer.peek(Tokens::Taxlabels)
          i = 0
          while @lexer.peek(Tokens::Label)
            @builder.update_taxon(:index => i, :name => @lexer.pop(Tokens::Label).value) 
            i += 1
          end 
          @lexer.pop(Tokens::SemiColon) if @lexer.peek(Tokens::SemiColon) # close of tax labels, placement of this seems dubious... but tests are working
        
        elsif  @lexer.peek(Tokens::MesquiteIDs)

          @lexer.pop(Tokens::MesquiteIDs) # trashing these for now
        elsif  @lexer.peek(Tokens::MesquiteBlockID)
          @lexer.pop(Tokens::MesquiteBlockID) 
        end
        
      end
    end


  end

  def parse_characters_blk 
    while true
      if @lexer.peek(Tokens::EndBlk) # we're at the end of the block, exit after geting rid of the semi-colon
        break 
      else		
        @lexer.pop(Tokens::Title) if @lexer.peek(Tokens::Title) # not used at present

        if @lexer.peek(Tokens::Dimensions)
          parse_dimensions
        end
        
        if @lexer.peek(Tokens::Format) 
          parse_format 
        end
        
        if @lexer.peek(Tokens::CharStateLabels)
          parse_chr_state_labels 
        end

        if @lexer.peek(Tokens::Matrix) 
          parse_matrix 
        end
        
        @lexer.pop(Tokens::MesquiteIDs) if @lexer.peek(Tokens::MesquiteIDs) # trashing these for now
        @lexer.pop(Tokens::MesquiteBlockID) if @lexer.peek(Tokens::MesquiteBlockID) # trashing these for now
        false
      end
    end
    @lexer.pop(Tokens::EndBlk)
  end

  # added by ChrisG
  def parse_data_blk
    if @lexer.peek(Tokens::Dimensions)
      parse_dimensions
    end

    if @lexer.peek(Tokens::Format)
      parse_format
    end

    if @lexer.peek(Tokens::Options)
      parse_options
    end

    if @lexer.peek(Tokens::CharLabels)
      parse_chr_labels
    end

    if @lexer.peek(Tokens::StateLabels)
      parse_state_labels
    end

    if @lexer.peek(Tokens::Matrix)
      parse_matrix
    end
  end

  # prolly pop header then fuse with parse_dimensions
  def parse_format
    @lexer.pop(Tokens::Format) 
    while @lexer.peek(Tokens::ValuePair)
      @builder.add_var(@lexer.pop(Tokens::ValuePair).value)
    end

    check_initialization_of_ntax_nchar

  end

  # added by ChrisG
  def parse_options
    @lexer.pop(Tokens::Options)
    while @lexer.peek(Tokens::ValuePair)
      @builder.add_var(@lexer.pop(Tokens::ValuePair).value)
    end
  end

  def parse_dimensions  
    @lexer.pop(Tokens::Dimensions)
    while @lexer.peek(Tokens::ValuePair)
      @builder.add_var(@lexer.pop(Tokens::ValuePair).value)
    end
    # the last value pair with a ; is automagically handled, don't try popping it again
    
    check_initialization_of_ntax_nchar
  end

  def check_initialization_of_ntax_nchar
    # check for character dimensions, if otherwise not set generate them
    if @builder.nexus_file.vars[:nchar] && @builder.nexus_file.characters == []
      (0..(@builder.nexus_file.vars[:nchar].to_i - 1)).each {|i| @builder.stub_chr }
    end
    
    # check for taxa dimensions, if otherwise not set generate them
    if @builder.nexus_file.vars[:ntax] && @builder.nexus_file.taxa == []
      (0..(@builder.nexus_file.vars[:ntax].to_i - 1)).each {|i| @builder.stub_taxon }
    end
  end


  def parse_chr_state_labels	
    @lexer.pop(Tokens::CharStateLabels)
  
    while true
      if @lexer.peek(Tokens::SemiColon)    
        break 
      else
        opts = {}
        name = ""
        index = @lexer.pop(Tokens::Number).value.to_i
        (name = @lexer.pop(Tokens::Label).value) if @lexer.peek(Tokens::Label) # not always given a letter

        @lexer.pop(Tokens::BckSlash) if @lexer.peek(Tokens::BckSlash)

        if !@lexer.peek(Tokens::Comma) || !@lexer.peek(Tokens::SemiColon)
          i = 0
          

          # three kludge lines, need to figure out the label/number priority, could be issue in list order w/in tokens
          while @lexer.peek(Tokens::Label) || @lexer.peek(Tokens::Number)
            opts.update({i.to_s => @lexer.pop(Tokens::Label).value}) if @lexer.peek(Tokens::Label)
            opts.update({i.to_s => @lexer.pop(Tokens::Number).value.to_s}) if @lexer.peek(Tokens::Number)

            i += 1
          end  
        end

        @lexer.pop(Tokens::Comma) if @lexer.peek(Tokens::Comma) # we may also have hit semicolon
        
        opts.update({:index => (index - 1), :name => name})
       
        raise(ParserError, "Error parsing character state labels for (or around) character #{index -1}.") if !opts[:name]
        @builder.update_chr(opts)
      end     
    end
    @lexer.pop(Tokens::SemiColon)
  end

  def parse_chr_labels
    @lexer.pop(Tokens::CharLabels)

    index = 1

    while true
      if @lexer.peek(Tokens::SemiColon)
        break
      else
        opts = {}
        name = ""
        index += 1
        (name = @lexer.pop(Tokens::Label).value) if @lexer.peek(Tokens::Label) # not always given a letter

        opts.update({:index => (index - 1), :name => name})

        raise(ParserError, "Error parsing character labels for (or around) character #{index -1}.") if !opts[:name]
        @builder.update_chr(opts)
    end

    end
    @lexer.pop(Tokens::SemiColon) 
  end

  def parse_state_labels
    @lexer.pop(Tokens::StateLabels)

    while true
      if @lexer.peek(Tokens::SemiColon)
        break
      else
        opts = {}
        name = ""
        index = @lexer.pop(Tokens::Number).value.to_i

        if !@lexer.peek(Tokens::Comma) || !@lexer.peek(Tokens::SemiColon)
          i = 0


          # three kludge lines, need to figure out the label/number priority, could be issue in list order w/in tokens
          while @lexer.peek(Tokens::Label) || @lexer.peek(Tokens::Number)
            opts.update({i.to_s => @lexer.pop(Tokens::Label).value}) if @lexer.peek(Tokens::Label)
            opts.update({i.to_s => @lexer.pop(Tokens::Number).value.to_s}) if @lexer.peek(Tokens::Number)

            i += 1
          end
        end

        @lexer.pop(Tokens::Comma) if @lexer.peek(Tokens::Comma) # we may also have hit semicolon

        opts.update({:index => (index - 1), :name => name})

        raise(ParserError, "Error parsing state labels for (or around) character #{index -1}.") if !opts[:name]
        @builder.update_chr(opts)
      end

    end
    @lexer.pop(Tokens::SemiColon)
  end

  def parse_matrix
    @lexer.pop(Tokens::Matrix)
    i = 0
      while true
        if @lexer.peek(Tokens::SemiColon)
         break 
        else
          t = @lexer.pop(Tokens::Label).value

          @builder.update_taxon(:index => i, :name => t) # if it exists its not re-added

          @builder.code_row(i, @lexer.pop(Tokens::RowVec).value)
      
          i += 1
        end
      end
    @lexer.pop(Tokens::SemiColon) # pop the semicolon 
  end

  # this suck(s/ed), it needs work when a better API for Mesquite comes out
  def parse_notes_blk
    # IMPORTANT - we don't parse the (CM <note>), we just strip the "(CM" ... ")" bit for now in NexusFile::Note

    @vars = {} 
    inf = 0
    while true
      inf += 1
      raise "Either you have a gazillion notes or more likely parser is caught in an infinite loop inside parse_notes_block" if inf > 100000
      if @lexer.peek(Tokens::EndBlk)
        @lexer.pop(Tokens::EndBlk)
        @builder.add_note(@vars) # one still left to add
        break
      else

        if @lexer.peek(Tokens::ValuePair)
          @vars.update(@lexer.pop(Tokens::ValuePair).value)
      
        elsif @lexer.peek(Tokens::Label)
          if @vars[:type] # we have the data for this row write it, and start a new one    
            
            @builder.add_note(@vars)
            @vars = {}
          else
            @vars.update(:type => @lexer.pop(Tokens::Label).value)
          end
        elsif @lexer.peek(Tokens::FileLbl)  
          @lexer.pop(Tokens::FileLbl)
          @vars.update(:file => 'file') # we check for whether :file key is present and handle conditionally
        end
      end
    end
  end

    #@vars = {}
    #while true
      
    #  break if  @lexer.peek(Tokens::EndBlk)   
      
    #  @vars.update(:type => @lexer.pop(Tokens::Label).value)

      # kludge to get around the funny construct that references file
     # if @lexer.peek(Tokens::FileLbl)
    #    @lexer.pop(Tokens::FileLbl)
    #      vars.update(:file => 'file') # we check for whether :file key is present and handle conditionally
     #   end

     #   while true

     #     meh = @lexer.pop(Tokens::ValuePair)          
     #     @vars.update(meh.value)
     #     break if !@lexer.peek(Tokens::ValuePair)
     #   end
     #   
     #   @builder.add_note(@vars)
     #   @vars = {}
    #end
   # @lexer.pop(Tokens::EndBlk)


  def parse_trees_blk
    true
  end

  def parse_labels_blk

  end

  def parse_sets_blk
  end

  def parse_assumptions_blk
  end

  def parse_codens_blk
    # not likely
  end

  def parse_mesquitecharmodels_blk
    # nor this
  end

  
  def parse_mesquite_blk

  end



  # def parse_children(parent)
  # parse a comma-separated list of nodes
  #  while true 
  #    parse_node(parent)
  #    if @lexer.peek(Tokens::Comma)
  #      @lexer.pop(Tokens::Comma)
  #    else
  #      break
  #    end
  #  end
  # end
  
end
