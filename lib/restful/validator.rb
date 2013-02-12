# Methods used to ensure that malicious code does not sneak through in user
# input.

module Restful
  class Validator
    def validate input, option_name
      case option_name
      when :conditions     then conditions input
      when :limit, :offset then number input
      when :select         then select input
      when :only           then word_list input
      when :include        then include_list_no_restricted(input)
      when :order          then order input
      when :joins          then select input # treat same as select
      end
    end

    private

    def no_restricted_terms(terms)
      terms.match(/user/i) ||
        terms.match(/password/i) ||
        terms.match(/login/i) ? nil : terms
    end

    def number(number)
      number && number.match(/^[\d\.]*$/) ? number : nil
    end

    def word(word)
      word && word.match(/^\w+$/) ? word : nil
    end

    def word_list(word_list)
      word_list && word_list.match(/^(\s*\w+,?\s*)+$/) ? word_list : nil
    end

    def include_list_no_restricted(struct)
      no_restricted_terms(struct) && word_hash_array_parser(struct)
    end

    def word_hash_array_parser(struct)
      destructable_struct = struct.clone
      _word_hash_array_parser(destructable_struct) && struct
    end

    def _word_hash_array_parser(struct)
      if struct =~ /^["']?\w*["']?$/x
        struct
      elsif struct.gsub!(/\[[\s"'\w\.,]+\]/x, '"v"')
        word_hash_array_parser(struct)
      elsif struct.gsub!(/\{\s*["']?\w+["']?:\s*["']?[\w\.]+["']?\}/x, '"v"')
        word_hash_array_parser(struct)
      else
        nil
      end
    end

    def conditions(string)
      #changed from '/^(([\w,]+(\[[\w\.]+\])?)(\+)?)+$/' to below
      #string && string.match(/^(([\w\.\-\s,%]+(\[\^?[\w\.]+\])?)(\+)?)*$/) ? string : nil
      string && string.match(/^(([\w\.\-\s,%\p{L}]+(\[\^?[\w\.]+\])?)(\+)?)*$/u) ? string : nil

    end

    def select(input)
      input && input.match(/^\[?(["']?[\w\.\*]+?["']?,?\s*)*\]?$/) ? input : nil
    end

    def order(input)
      input && input.match(/^[\w+\.\s+]+$/)
    end
  end
end
