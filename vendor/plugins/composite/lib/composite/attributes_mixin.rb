module Composite::AttributesMixin
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def composite label, attrs = nil
      if attrs
        (@composite ||= {})[label.to_sym]= Composite::Attribute.new(label.to_sym, attrs)
      else
        (@composite ||= {})[label.to_sym]
      end
    end

    def attr? label
      (columns_hash[label.to_s] || composite(label.to_sym) || label.to_s == '*') ? true : false
    end
  end
end