class NexusParser
  module Tokens

    class Token
      # this allows access the the class attribute regexp, without using a class variable
      class << self
        attr_reader :regexp
        def matches?(input)
          !!self.regexp.match(input)
        end
      end
      attr_reader :match
      def initialize(input)
        @match = self.class.regexp.match(input)
      end
      def value
        @value ||= @match ? @match[1] : nil
      end
    end

    class NexusStart < Token
      @regexp = Regexp.new(/\A.*(\#nexus)\s*/i)
    end

    class BeginBlk < Token
      @regexp = Regexp.new(/\A\s*(\s*Begin\s*)/i)
    end

    class EndBlk < Token
      @regexp = /\A\s*(END(BLOCK)?\s*;)\s*/i
    end

    class AuthorsBlk < Token
      @regexp = Regexp.new(/\A\s*(Authors;.*?END(BLOCK)?\s*;)\s*/im)
    end

    class TaxaBlk < Token
      @regexp = Regexp.new(/\A\s*(\s*Taxa\s*;)\s*/i)
    end

    class DataBlk < Token
      @regexp = Regexp.new(/\A\s*(\s*Data\s*;)\s*/i)
    end

    # label
    class NotesBlk < Token
      @regexp = Regexp.new(/\A\s*(\s*Notes\s*;.*?END(BLOCK)?\s*;)\s*/im)
    end

    class FileLbl < Token
      @regexp = Regexp.new(/\A\s*(\s*File\s*)\s*/i)
    end

    # label and content
    class Title < Token
      @regexp = Regexp.new(/\A\s*(title[^\;]*;)\s*/i)
    end

    class Dimensions < Token
      @regexp = Regexp.new(/\A\s*(DIMENSIONS)\s*/i)
    end

    class Format < Token
      @regexp = Regexp.new(/\A\s*(format)\s*/i)
    end

    class Options < Token
      @regexp = Regexp.new(/\A\s*(options)\s*/i)
    end

    # label
    class Taxlabels < Token
      @regexp = Regexp.new(/\A\s*(\s*taxlabels\s*)\s*/i)
    end

    class Label < Token
      @regexp = /\A\s*(('([^']+)')|("([^"]+)")|([^\/,\;\s]+))\s*/ #  matches "foo and stuff", foo, 'stuff or foo', 'foo, and stuff', 1.2 BUT NOT 1/2 foo;stuff or foo, and stuff
      def value
        @value ||= (match[3] || match[5] || match[6]).strip # take value inside parens or whole thing if no parens given
      end
    end

    class ChrsBlk < Token
      @regexp = Regexp.new(/\A\s*(characters\s*;)\s*/i)
    end

    # note we grab EOL and ; here
    class ValuePair < Token
      @regexp = Regexp.new(/\A\s*([\w\d\_\&]+\s*=\s*((\'[^\']+\')|(\(.*\))|(\"[^\"]+\")|([^\s\n\t;]+)))[\s\n\t;]+/i) #  returns key => value hash for tokens like 'foo=bar' or foo = 'b a ar'
      def value
        @value ||= Proc.new {
          str = match[1]
          str.strip!
          str = str.split(/=/)
          str[1].strip!
          str[1] = str[1][1..-2] if str[1][0..0] == "'"
          str[1] = str[1][1..-2] if str[1][0..0] ==  "\""
          {str[0].strip.downcase.to_sym => str[1].strip}
        }.call
      end
    end

    class Matrix < Token
      @regexp = /\A\s*(matrix)\s*/i
    end

    class RowVec < Token
      @regexp = /\A\s*(.+?)\s*[\r\n]+/im
      def value
        @value ||= Proc.new {
          str = match[1]
          code_array = [ ]
          chars_array = str.strip.chars.to_a.reverse # arrange array as a stack
          until chars_array.empty?
            char = chars_array.pop
            # characters within brackets should be treated as state codings for one character
            if char =~ /[\{\(]/
              multicode = ""
              until (char = chars_array.pop) =~ /[\}\)]/
                multicode << "#{char} " unless char.strip.blank?
              end
              code_array << multicode.strip
            else
              code_array << char
            end
          end
          code_array
        }.call
      end
    end

    class CharStateLabels < Token
      @regexp = Regexp.new(/\A\s*(CHARSTATELABELS)\s*/i)
    end

    class CharLabels < Token
      @regexp = Regexp.new(/\A\s*(CHARLABELS)\s*/i)
    end

    class StateLabels < Token
      @regexp = Regexp.new(/\A\s*(STATELABELS)\s*/i)
    end

    class MesquiteIDs < Token
      @regexp = Regexp.new(/\A\s*(IDS[^;]*;)\s*/i)
    end

    class MesquiteBlockID < Token
      @regexp = Regexp.new(/\A\s*(BLOCKID[^;]*;)\s*/i)
    end

    # unparsed blocks

    class GenericBlk < Token
      @regexp = /\A\s*(\w+;.*?END(BLOCK)?;)\s*/im # note the multi-line /m
    end

    class BlkEnd < Token
      @regexp = Regexp.new(/\A[\s\n]*(END;)\s*/i)
    end

    class LBracket < Token
      @regexp = Regexp.new('\A\s*(\[)\s*')
    end

    class RBracket < Token
      @regexp = Regexp.new('\A\s*(\])\s*')
    end

    class LParen < Token
      @regexp = Regexp.new('\A\s*(\()\s*')
    end

    class RParen < Token
      @regexp = Regexp.new('\A\s*(\))\s*')
    end

    class Equals < Token
      @regexp = Regexp.new('\A\s*(=)\s*')
    end

    class BckSlash < Token
      @regexp = Regexp.new('\A\s*(\/)\s*')
    end

    # labels
    class ID < Token
      @regexp = Regexp.new('\A\s*((\'[^\']+\')|(\w[^,:(); \t\n]*|_)+)\s*')
      def value
        @value ||= Proc.new {
          str = match[1]
          str.strip!
          str = str[1..-2] if str[0..0] == "'" # get rid of quote marks
          str
        }.call
      end
    end

    class Colon < Token
      @regexp = Regexp.new('\A\s*(:)\s*')
    end

    class SemiColon < Token
      @regexp = Regexp.new('\A\s*(;)\s*')
    end

    class Comma < Token
      @regexp = Regexp.new('\A\s*(\,)\s*')
    end

    class Number < Token
      @regexp = Regexp.new('\A\s*(-?\d+(\.\d+)?([eE][+-]?\d+)?)\s*')
      def value
        @value ||= (match[1] =~ /\./) ? match[1].to_f : match[1].to_i
      end
    end

    # this list also defines priority, i.e. if tokens have overlap (which they shouldn't!!) then the earlier indexed token will match first
    def Tokens.list
      [ NexusParser::Tokens::NexusStart,
        NexusParser::Tokens::BeginBlk,
        NexusParser::Tokens::EndBlk,
        NexusParser::Tokens::AuthorsBlk,
        NexusParser::Tokens::TaxaBlk,
        NexusParser::Tokens::NotesBlk,
        NexusParser::Tokens::DataBlk,
        NexusParser::Tokens::Title,
        NexusParser::Tokens::Taxlabels,
        NexusParser::Tokens::Dimensions,
        NexusParser::Tokens::FileLbl,
        NexusParser::Tokens::Format,
        NexusParser::Tokens::Options,
        NexusParser::Tokens::Equals,
        NexusParser::Tokens::ValuePair,  # this has bad overlap with Label and likely IDs (need to kill the latter, its a lesser Label)
        NexusParser::Tokens::CharStateLabels,
        NexusParser::Tokens::CharLabels,
        NexusParser::Tokens::StateLabels,
        NexusParser::Tokens::ChrsBlk,
        NexusParser::Tokens::Number,
        NexusParser::Tokens::Matrix,
        NexusParser::Tokens::SemiColon,
        NexusParser::Tokens::MesquiteIDs,
        NexusParser::Tokens::MesquiteBlockID,
        NexusParser::Tokens::BlkEnd,
        NexusParser::Tokens::Colon,
        NexusParser::Tokens::BckSlash,
        NexusParser::Tokens::Comma,
        NexusParser::Tokens::LParen,
        NexusParser::Tokens::RParen,
        NexusParser::Tokens::LBracket,
        NexusParser::Tokens::RBracket,
        NexusParser::Tokens::Label, # must be before RowVec
        NexusParser::Tokens::RowVec,
        NexusParser::Tokens::ID # need to trash this
      ]
    end
  end
end