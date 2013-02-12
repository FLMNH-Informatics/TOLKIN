module SyncRecords
  module SelectScope
    def self.included(klass)
      klass.class_eval do
        class << self
          def select_scope name, scope = {}
            @select_scopes ||= {}
            @select_scopes[name] ||= scope
          end
        end
      end
    end
  end
end
