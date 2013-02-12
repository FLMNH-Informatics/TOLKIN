module GenericSearchHelper
  class Helper
    def self.get_base(key)
      ["_like", "_lte", "_gte"].each do |seperator|
        return key.chomp(seperator) if(key.chomp(seperator) != key)
      end
      key
    end

#    def self.sanitize!(search_params, selected_filters = [])
#      selected_filters ||= []
#      search_params.delete_if{ |key, val| !selected_filters.include?(get_base(key))} if search_params
#    end
  end
end
