class AdminController < ApplicationController
#  def show
#    @users = User.with_roles_in_project(current_project).all
#    #@roles = current_project.roles
#  end

  def list_users

     @users =
      (current_user.is_admin? ? User : User.with_roles_in_project(current_project)).
        order([:last_name, :first_name ]).
        select([:user_id, :first_name, :last_name, :username, :email, :enabled ]).
        all.
        paginate(
          :page => params[:page],
          :per_page => 20
        )

  end
end
