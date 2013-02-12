

class NexusParser::Output
  attr_accessor :taxa, :characters, :sets, :codings, :vars, :notes

  def initialize
    @taxa = []
    @characters = []
    @sets = []
    @codings = []
    @notes = []
    @vars = {}
  end

  class Character
    attr_accessor :name, :index, :states, :notes, :id # id field is specifically for Tolkin
    def initialize(index, name, options = {})
      @name = name
      @index = index
      @states = options[:states] || []
      @notes = options[:notes] || []
    end

    # requires :label
#    def add_state(options = {})
#      @opt = {
#        :name => ''
#      }.merge!(options)
#      return false if !@opt[:label]
#
#      @states[@opt[:label]] = NexusParser::Output::ChrState.new(@opt[:name])
#    end

    # test this
    def state_labels
      (0..@states.size).inject([]) { |arr, i| arr.push(i) }
    end

    def name
      ((@name == "") || (@name == nil)) ? "Undefined" : @name
    end
  end

  class Taxon
    attr_accessor :name, :index, :mesq_id, :notes, :id # id field is specifically for Tolkin
    def initialize(index, name, options = {})
      @name = name
      @index = index
      @mesq_id = options[:mesq_id]
      @notes = options[:notes] || [ ]
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
      @states = options[:states] || []
      @notes = [] 
    end

    def states
      [*@states]
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

## the actual method
#def parse_nexus_file(input)
#  print "***************Inside Parse Block***************"
#  @input = input
#  @input.gsub!(/\[[^\]]*\]/,'')  # strip out all comments BEFORE we parse the file
#
#  builder = OutputBuilder.new
#  lexer = Lexer.new(@input)
#  Parser.new(lexer, builder).parse_file
#  return builder.nexus_file
#end



