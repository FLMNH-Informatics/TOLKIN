module Authorized
  class Passkey
    def user u = nil
      u ? (@user = u) && self : @user
    end

    def project p = nil
      p ? (@project = p) && self : @project
    end

    def unlock modelClass, options = { to: 'view' }
      user && project ? 
        modelClass.authorize(self, options) :
        fail("key has not been authorized for a user and project")
    end
  end
end