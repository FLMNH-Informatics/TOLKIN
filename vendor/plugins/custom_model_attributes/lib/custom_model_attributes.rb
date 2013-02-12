module CustomModelAttributes
  def attrs_custom atts = nil
    unless atts.nil?
      @attrs_custom = atts
#      extend ClassMethods
      include InstanceMethods
    else
      @attrs_custom
    end
  end

#  module ClassMethods
#  end

  module InstanceMethods
    def self.included(mod)
      mod.attrs_custom.each do |k,v|
        define_method(k) { v[:eval][self] }
      end
    end
  end
end

ActiveRecord::Base.send(:extend, CustomModelAttributes)