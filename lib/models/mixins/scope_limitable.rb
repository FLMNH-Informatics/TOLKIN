module Models
  module Mixins
    module ScopeLimitable
      def self.included(base)
        base.class_exec {
          scope :limit, lambda { |limit| { :limit => limit } }
        }
      end
    end
  end
end
