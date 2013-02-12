class Array
    def all_with_index?
      each_with_index do |elem,i|
        return false unless yield elem,i
      end
      return true
    end
end
