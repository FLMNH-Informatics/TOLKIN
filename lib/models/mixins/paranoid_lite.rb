module Models
  module Mixins
    module ParanoidLite
      def self.included(base)
        base.class_exec { 
          default_scope :conditions => { :deleted_at => nil }
        }
      end

      def destroy!
        self.deleted_at = Time.now
        save!
      end

      def destroy
        self.deleted_at = Time.now
        save
      end
    end
  end
end
