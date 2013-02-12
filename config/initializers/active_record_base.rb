module ActiveRecord
  class Base
    def quoted_attribute att_name
      quote_value(send(att_name), column_for_attribute(att_name))
    end
  end
end
