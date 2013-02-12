# Methods used to ensure that malicious code does not sneak through in user
# input.
module Validated

  class << self

    def number(number)
      number && number.match(/^[\d\.]+$/) ? number : nil
    end

    def word(word)
      word && word.match(/^\w+$/) ? word : nil
    end

    def word_list(word_list)
      word_list && word_list.match(/^(\w+,?\s*)+$/) ? word_list : nil
    end

  end
end
