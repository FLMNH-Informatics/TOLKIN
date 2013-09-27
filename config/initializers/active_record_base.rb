module ActiveRecord
  class Base
    after_initialize :sanitize_attributes
    before_save :sanitize_attributes

    def quoted_attribute att_name
      quote_value(send(att_name), column_for_attribute(att_name))
    end

    def sanitize_attributes
      self.attributes.each do |att|
        #self[att.first] = self[att.first].gsub(/\<script\>/,'&lt;script&gt;').gsub(/\<script\\\>/,'&lt;/script&gt') if self[att.first].is_a? String
        self[att.first] = self[att.first].gsub(/\</,'&lt;').gsub(/>/,'&gt;') if self[att.first].is_a? String
      end
    end
  end
end
