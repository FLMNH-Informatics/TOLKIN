module Authorized
  module ActionController
    module ProvidesPasskey

      def self.included(klass)
        klass.class_eval do
          before_filter :init_passkey

          attr_reader :passkey, :admin_passkey

          def init_passkey
            @passkey ||=
              current_user &&
              current_project &&
              Authorized::Passkey.new.
                user(current_user).
                project(current_project)

            @admin_passkey ||=
              current_project &&
              Authorized::Passkey.new.
                user(current_user).
                project(current_project)
            ##this may not be necessary

          end
        end
      end
    end
  end
end