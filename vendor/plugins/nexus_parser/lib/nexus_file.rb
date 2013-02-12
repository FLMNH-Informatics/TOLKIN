# NexusParser

# version 0.2 by Matt Yoder 
# uses the PhyloTree parser/lexer engine by Krishna Dole which in turn was based on
# Thomas Mailund's <mailund@birc.dk> 'newick-1.0.5' Python library

# outstanding issues:
## need to resolve Tokens Labels, ValuePair, IDs

require File.expand_path(File.join(File.dirname(__FILE__), 'tokens'))
require File.expand_path(File.join(File.dirname(__FILE__), 'parser'))
require File.expand_path(File.join(File.dirname(__FILE__), 'lexer'))


class NexusFile # Node
  attr_accessor :taxa, :characters, :sets, :codings, :vars, :notes

  def initialize
    @taxa = []
    @characters = []
    @sets = []
    @codings = []
    @notes = []
    @vars = {}
  end

  # def cell(taxon, character)
  #  @codings[taxon][character]
  # end
 
  class Character
    attr_accessor :name, :states, :notes
    def initialize
      @name = nil
      @states = {}
      @notes = []
    end

    # requires :label
    def add_state(options = {})
      @opt = {
        :name => ''
      }.merge!(options)
      return false if !@opt[:label]
      
      @states.update(@opt[:label] => ChrState.new(@opt[:name]))
    end

    # test this
    def state_labels
      @states.keys.sort
    end

    def name
      ((@name == "") || (@name == nil)) ? "Undefined" : @name
    end
  end

  class Taxon
    attr_accessor :name, :mesq_id, :notes
    def initialize
      @name = ""
      @mesq_id = ""
      @notes = []
    end
  end

  class ChrState
    # state is stored as a key in Characters.states
    attr_accessor :name, :notes
    def initialize(name)
      @name = name
    end
  end

  class Coding 
    # unfortunately we need this for notes  
    attr_accessor :states, :notes
    def initialize(options = {})
      @states = options[:states]
      @notes = [] 
    end

    def states
      @states.class == Array ? @states  :  [@states]
    end
  end

  class Note
    attr_accessor :vars
    def initialize(options = {})
      @vars = options
    end

    def note
      n = ''
      if @vars[:tf]
        n = @vars[:tf]
      elsif @vars[:text]
        n = @vars[:text]
      else
        n = 'No text recovered, possible parsing error.'
      end
      
      # THIS IS A HACK for handling the TF = (CM <note>) format, I assume there will be other params in the future beyond CM, at that point move processing to the parser
      if n[0..2] =~ /\A\s*\(\s*CM\s*/i
        n.strip!
        n = n[1..-2] if n[0..0] == "(" # get rid of quotation marks
        n.strip!
        n = n[2..-1] if n[0..1].downcase == "cm" # strip CM
        n.strip!
        n = n[1..-2] if n[0..0] == "'" # get rid of quote marks
        n = n[1..-2] if n[0..0] == '"' 
      end
      n.strip
    end
  end

end


class NexusFileBuilder # TreeBuilder

  # intermediate b/w NexusFile and Parser

  # methods to build the
  def initialize
    @nf =  NexusFile.new 
  end

  # does the building, since we don't recurse here its pretty straight forward
#  def new_nexus_file
#    @nf = NexusFile.new # returns a new Nexus file object
#  end

  def stub_taxon
    @nf.taxa.push(NexusFile::Taxon.new) 
    return @nf.taxa.size
  end

  def stub_chr
    @nf.characters.push(NexusFile::Character.new)
    return @nf.characters.size
  end

  def code_row(taxon_index, rowvector)

    @nf.characters.each_with_index do |c, i|
      @nf.codings[taxon_index.to_i] = [] if !@nf.codings[taxon_index.to_i]
      @nf.codings[taxon_index.to_i][i] = NexusFile::Coding.new(:states => rowvector[i])
    
      # !! we must update states for a given character if the state isn't found (not all states are referenced in description !! 

      existing_states = @nf.characters[i].state_labels
      
      new_states = rowvector[i].class == Array ? rowvector[i].collect{|s| s.to_s} :  [rowvector[i].to_s]
      new_states.delete("?") # we don't add this to the db
      new_states = new_states - existing_states

      new_states.each do |s|
        @nf.characters[i].add_state(:label => s)
      end

    end
  end

  def add_var(hash)
    hash.keys.each do |k|
      raise "var #{k} has already been set" if @nf.vars[:k]
    end
    @nf.vars.update(hash)
  end
  
  def update_taxon(options = {})
    
    @opt = {
      :name => ''
    }.merge!(options)
    return false if !@opt[:index]
    (@nf.taxa[@opt[:index]].name = @opt[:name]) if @opt[:name]
  end

  # legal hash keys are :index, :name, and integers that point to state labels
  def update_chr(options = {} )
    @opt = {
      :name => ''
    }.merge!(options)
    return false if !@opt[:index]

    @index = @opt[:index].to_i
    
    # need to create the characters
    
    raise(ParseError, "Can't update character of index #{@index}, it doesn't exist! This is a problem parsing the character state labels. Check the indices. It may be for this character \"#{@opt[:name]}\".") if !@nf.characters[@index]

    (@nf.characters[@index].name = @opt[:name]) unless @opt[:name].empty?
  
    @opt.delete(:index)
    @opt.delete(:name)
   
    # the rest have states
    @opt.keys.each do |k|
      
      if (@nf.characters[@index].states != {}) && @nf.characters[@index].states[k] # state exists
        
        ## !! ONLY HANDLES NAME, UPDATE TO HANDLE notes etc. when we get them ##
        update_state(@index, :index => k, :name => @opt[k])
        
      else # doesn't, create it
        @nf.characters[@index].add_state(:label => k.to_s, :name => @opt[k])
      end
    end
    
  end

  def update_state(chr_index, options = {})
    # only handling name now
    #options.keys.each do |k|
      @nf.characters[chr_index].states[options[:index]].name = options[:name]
        # add notes here
    # end
  end

  def add_note(options = {})
    @opt = {
      :text => ''
    }.merge!(options)

    case @opt[:type]

    # Why does mesquite differentiate b/w footnotes and annotations?!, apparently same data structure?
    when 'TEXT' # a footnote 
      if @opt[:file]
       @nf.notes << NexusFile::Note.new(@opt)
        
      elsif  @opt[:taxon] && @opt[:character] # its a cell, parse this case         
        @nf.codings[@opt[:taxon].to_i - 1][@opt[:character].to_i - 1].notes = [] if !@nf.codings[@opt[:taxon].to_i - 1][@opt[:character].to_i - 1].notes
        @nf.codings[@opt[:taxon].to_i - 1][@opt[:character].to_i - 1].notes << NexusFile::Note.new(@opt)

      elsif @opt[:taxon] && !@opt[:character]
        @nf.taxa[@opt[:taxon].to_i - 1].notes << NexusFile::Note.new(@opt)

      elsif @opt[:character] && !@opt[:taxon]
        
        @nf.characters[@opt[:character].to_i - 1].notes << NexusFile::Note.new(@opt)
      end

    when 'AN' # an annotation, rather than a footnote, same dif
      if @opt[:t] && @opt[:c]
        @nf.codings[@opt[:t].to_i - 1][@opt[:c].to_i - 1].notes = [] if !@nf.codings[@opt[:t].to_i - 1][@opt[:c].to_i - 1].notes
        @nf.codings[@opt[:t].to_i - 1][@opt[:c].to_i - 1].notes << NexusFile::Note.new(@opt)
      elsif @opt[:t]
        @nf.taxa[@opt[:t].to_i - 1].notes << NexusFile::Note.new(@opt)
      elsif @opt[:c]
        @nf.characters[@opt[:c].to_i - 1].notes << NexusFile::Note.new(@opt)
      end
    end
    
  end

  def nexus_file
    @nf
  end

end

class ParseError < StandardError
end

# the actual method
def parse_nexus_file(input)

  print "***************Inside Parse Block***************"

  @input = input
  @input.gsub!(/\[[^\]]*\]/,'')  # strip out all comments BEFORE we parse the file

    
  # quickly peek at the input, does this look like a Nexus file? 
#  if !(@input =~ /\#Nexus/i) || !(@input =~ /Begin/i) || !(@input =~ /Matrix/i) || !(@input =~ /end\;/)
#    raise(ParseError, "File is missing at least some required headers, check formatting.", caller)
#  end

  builder = NexusFileBuilder.new
  lexer = Lexer.new(@input)
  Parser.new(lexer, builder).parse_file
  return builder.nexus_file  
end



