class NexusParser::Lexer
  attr_reader :input

  def initialize(input)
    @input = input
  end
  
  # checks whether the next token is of the specified class. 
  def peek(token_class)
    read_next_token(token_class).class == token_class
  end

  # return (and delete) the next token from the input stream, or raise an exception
  # if the next token is not of the given class.
  def pop(token_class)
    token = read_next_token(token_class)
    fail ParseError, "expected #{token_class} but received #{token.class} at #{@input[0..10]}..." unless token.class == token_class
    @input.slice!(0..(token.match.end(0) - 1)) # trim token from input string if token is valid
    token
  end
  
  private
  # read (and store) the next token from the input, if it has not already been read.
  def read_next_token(token_class)
    token = token_class.matches?(@input) ?
      token_class.new(@input) : # retrieve token if input matches token class
      NexusParser::Tokens.list.find { |klass| klass.matches?(@input) }.try(:new, @input) # or search for correct token if it doesn't and return that
    raise( ParseError, "Lex Error, unknown token at #{@input[0..10]}...", caller) unless token || @input.blank? # no match, either end of string or lex error
    token
  end
end
