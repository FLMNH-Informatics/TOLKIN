# keep track of applied scopes
module Authorized
  module Scope
    def self.included(klass)
      klass.class_eval do
        def self.scope name, scope_options = {}
          if scope_options.respond_to?(:call)
            super(name, lambda { |*args|
              out = scope_options.call(*args)
              out.applied_scopes.add(name)
              out
            })
          else
            super(name, scope_options)
          end
        end
      end
    end
  end
end
