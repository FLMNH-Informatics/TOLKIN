module ActiveRecord
  class Base
    class << self
      def has_column? col
        !!columns_hash[col.to_s]
      end
    end
  end
end