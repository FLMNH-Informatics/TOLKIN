module ActiveRecord
  class Base
    class << self
      def member_name
        self.to_s.demodulize.underscore
      end

      def collection_name
        self.to_s.demodulize.underscore.pluralize
      end
    end
  end
end