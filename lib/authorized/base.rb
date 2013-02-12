module Authorized
  module Base
    def self.included(mod)
      mod.class_eval do
        include Authorized::Scope
        include Authorized::Scopes
        include Authorized::Persistence

        attr_reader :authorized

        def update_authorized?
          authorized.user.is_admin? ||
            record_permissions.permits(authorized.user, to: :edit).any?
#          self.permissions.editable_by_user?(passkey.user)
#          fail "no of course not"
        end

        def create_authorized?
          true # TODO: don't leave like this for long - needs to check type permissions system
        end

        def authorize passkey
          @authorized = passkey
          self
        end

#        def attributes=(new_attributes)
#          super
#          self.new_version = version.clone
#          new_version.attributes.merge(new_attributes)
#        end
      end
    end
  end
end