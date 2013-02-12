#require 'lexer'

####################### start of lexer transfer this to another file
class SourcePos
    attr_reader :line, :column, :file
    
    def initialize(line, column, file)
      @line = line
      @column = column
      @file = file
    end

    def to_s
      "#{file}:#{line}"
    end
  end

  class RuleSet
    def initialize
      @rules = []
    end

    def match(regexp, result)
      @rules << [regexp, result]
    end

    def literals(words)
      words.each do |w|
        match /#{w}/, w
      end
    end

    def each
      @rules.each do |pair|
        yield pair[0], pair[1]
      end
    end
  end

  class LexerError < RuntimeError
    attr_reader :src_pos
    
    def initialize(mess, src_pos)
      super(mess)
      @src_pos = src_pos
    end
  end

  class Lexer
    attr_reader :lval, :ignore_whitespace
    attr_accessor :ignore_newlines, :file_name
    
    def initialize(ignore_whitespace = false)
      @scanner = StringScanner.new('')
      @rules = RuleSet.new
      @ignore_whitespace = ignore_whitespace
      @ignore_newlines = ignore_whitespace
      @lineno = 1
      @file_name = '<unknown>'
      yield @rules
    end

    # ignore_whitespace turns on ignore_newlines too
    def ignore_whitespace=(b)
      @ignore_whitespace = b
      @ignore_newlines = b
    end
    
    def feed(str)
      @scanner = StringScanner.new(str)
      @cols_prev = 0
    end

    def src_pos
      SourcePos.new(@lineno, @scanner.pos - @cols_prev, @file_name)
    end
    
    def next_token!
      ##debugger
      if @scanner.check /^\s*\n/ then
        @lineno += 1
        @cols_prev = @scanner.pos + 1
      end
      skip_whitespace
      @rules.each do |regexp, result|
        return result if @lval = @scanner.scan(regexp)
      end
      unexpect = if @scanner.rest.length < 10 then
                   @scanner.rest
                 else
                   "#{@scanner.rest.first 10}..."
                 end
      raise LexerError.new("Unexpected input #{unexpect}", src_pos)
    end

    def peek_token
      ##debugger
      tok = self.next_token!
      @scanner.unscan
      return tok
    end

    def peek_lval
      #peek_token
      @lval
    end

    def more_tokens?
      skip_whitespace
      not @scanner.eos?
    end

    private

    def skip_whitespace
      if @ignore_newlines and @ignore_whitespace then
        @scanner.skip /\s+/
      elsif @ignore_whitespace then
        @scanner.skip /[ \t\r]+/
      elsif @ignore_newlines  then
        @scanner.skip /[\r\n]+/
      end
    end
  end
####################### end of lexer
class BibtexParser < CitationParser

  def initialize
      ##debugger
      super()
      @lexer = Lexer.new(true) do |rules|
        ##debugger
      rules.match /@/, :at
      rules.match /\{/, :lbrace
      rules.match /\}/, :rbrace
      rules.match /\"/, :dquote
      rules.match /\=/, :equals
      rules.match /\,/, :comma
      rules.match /[\w\-_:]+/, :id
      rules.match /.+?/, :cdata
    end
  end

  def parse(data)
    begin
            #if row_count.size < 1
            #  return nil
            #end
            ##debugger
            @lexer.feed data
            #@citations = Bibliography.new
            while @lexer.more_tokens?
              @citations << parse_entry
            end

            @citations.each do |c|
              puts("\n\nCitation: #{c.inspect}\n\n")
            end
            
            puts("\nCitations Size: #{@citations.size}\n")
            puts("\nRefworksParser says:#{@citations.each{|c| c.inspect}}\n")
            
            @citations
    rescue
        #debugger
        return nil
    end
  end
  

    def parse_entry
      expect :at, '@'
      type = expect :id
      expect :lbrace, '{'
      key = expect :id

      #debugger
      #e = Entry.new(type, key)
      c = ParsedCitation.new(:bibtex, type, key)
      while @lexer.peek_token != :rbrace
        expect :comma, ','
        key, value = parse_field
        c.properties[key] = value
      end

      expect :rbrace, '}'
      return c
    end

    def parse_field
      #debugger
      key = expect :id
      expect :equals, '='
      value = parse_value
      [key.to_s.downcase.intern, value] #here all the attributes are converted to lowercase
    end

    def parse_value
      #debugger
      close = :rbrace
      if @lexer.peek_token == :dquote then
        expect :dquote
        close = :dquote
      else
        expect :lbrace, '{'
      end

      brace_count = 1
      str = ''
      @lexer.ignore_whitespace = false
      @lexer.ignore_newlines = true
      loop do
        unless @lexer.more_tokens?
          raise 'Unexpected end of input'
        end
        
        case @lexer.next_token!
        when :rbrace, close
          brace_count -= 1
          if brace_count == 0 then
            @lexer.ignore_whitespace = true
            return str
          else
            str += '}'
          end
        when :lbrace
          str += '{'
          brace_count += 1
        else
          str += @lexer.lval
        end
      end
    end

    def expect(token, pretty = nil)
      ##debugger
      pretty ||= token.to_s
      got = @lexer.next_token!
      unless got == token then
      #debugger
        raise "TOKEN NOT FOUND"
        #raise "#{@lexer.src_pos}: Expected '#{pretty}' but found '#{got}'"
      else
        @lexer.lval
      end
    end



  def param_hash(xml)
    return {
      :ref_type => (xml/:rt).inner_html.to_a,
      :author_primary => (xml/:a1).collect{|a| a.inner_html},
      :author_secondary => (xml/:a2).collect{|a| a.inner_html},
      :title_primary => (xml/:t1).inner_html.to_a,
      :title_secondary => (xml/:t2).inner_html.to_a,
      :title_tertiary => (xml/:t3).inner_html.to_a,
      :keyword => (xml/:k1).collect{|k| k.inner_html},
      :pub_year => (xml/:yr).inner_html.to_a,
      :pub_date => (xml/:fd).inner_html.to_a,
      :periodical_full => (xml/:jf).inner_html.to_a,
      :periodical_abbrev => (xml/:jo).inner_html.to_a,
      :volume => (xml/:vo).inner_html.to_a,
      :issue => (xml/:is).inner_html.to_a,
      :start_page => (xml/:sp).inner_html.to_a,
      :other_pages => (xml/:op).inner_html.to_a,
      :edition => (xml/:ed).inner_html.to_a,
      :publisher => (xml/:pb).inner_html.to_a,
      :place_of_publication => (xml/:pp).inner_html.to_a,
      :issn_isbn => (xml/:sn).inner_html.to_a,
      :author_address_affiliations => (xml/:ad).inner_html.to_a,
      :accession_number => (xml/:an).inner_html.to_a,
      :language => (xml/:la).inner_html.to_a,
      :subfile_database => (xml/:sf).inner_html.to_a,
      :links => (xml/:lk).inner_html.to_a,
      :doi => (xml/:do).inner_html.to_a,
      :abstract => (xml/:ab).inner_html.to_a,
      :notes => (xml/:no).inner_html.to_a,
      :user_1 => (xml/:u1).inner_html.to_a,
      :user_2 => (xml/:u2).inner_html.split(/\||;/),
      :user_3 => (xml/:u3).inner_html.to_a,
      :user_4 => (xml/:u4).inner_html.to_a,
      :user_5 => (xml/:u5).inner_html.to_a,
      :original_data => xml
    }
  end 
end

