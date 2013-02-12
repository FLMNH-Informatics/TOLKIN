module Authorized
  module Scopes
    def self.included(klass)
      klass.class_eval do
        scope :authorize, lambda{ |passkey, options = { to: 'view' }|
          ( passkey.user.is_admin? ?
            self :
            self.permitted_for(passkey.user, options)
          ).
            in_project(passkey.project).
            authorized(passkey)
        }

        scope :permitted_for, lambda { |user, options = {}|
          self.
            joins(
              record_permissions: {
                role: :role_member_users }
            ).
            where(
              record_permissions: {
                Permission.name_for_action(options[:to]) => true,
                role: {
                  role_member_users: { obj_rtid: user.rtid }}}
            )
        }

        scope :in_project, lambda { |project|
          where(owner_graph_rtid: project.rtid)
        }
      end
    end
  end
end