class GrantedRolesController < ApplicationController

  #layout 'standard'
  before_filter :requires_any_manager

  #TODO this is really hacked and specific to preset database roles, generalize this a bit
  def index
    if is_admin?
      @projects = Project.all
    else
      # get all projects for which current user has role of manager
      @projects = Project.find_by_sql ["select * from projects where id in
                                        (select project_id from granted_roles where user_id=? and role_type_id=
                                        (select id from role_types where name='manager'))", current_user.id]
    end

    @user = User.find(params[:user_id])
    @user_roles = @user.granted_roles.for_projects(@projects)
    max_rank = current_user.role_types.maximum('rank')
    @pending_project_requests = @user.pending_project_requests

    if(!is_admin?)
      @roles = RoleType.find(:all, :conditions => [ "rank < ?", max_rank ])
    else
      @roles = RoleType.all
    end

  end

  
  def update

    #TODO work on limiting scope of permissions granted based on own permissions on a project
    @user = User.find(params['granted_roles']['user_id'])
    role_type = RoleType.find(params['granted_roles']['role_type_id'])
    project = Project.find(params['granted_roles']['project_id'])

    current_user_role = current_user.granted_roles.find_by_project_id(project.id)
    current_user_rank = get_current_user_rank(current_user_role)

    success = true

    # don't allow user to grant themselves privileges
    if(current_user.id == @user.id)
      flash[:error] = "Role not granted. You cannot grant new privileges to yourself."
      success = false
    end

    # user must have at least rank of at least manager on current project to grant roles
    if current_user_rank < RoleType.find_by_name('manager').rank
      flash[:error] = "Role not granted. You must have a rank of at least manager to grant roles on a project."
      success = false
    end

    # users role on the specified project must be greater than the role they are granting
    if !is_admin? && current_user_rank <= role_type.rank
      flash[:error] = "Role not granted. Your role on this project must be greater than that of the role you are granting."
      success = false
    end

    if success
      old_project_role = @user.granted_roles.find_by_project_id(project.id)
      # update old user role for project if it exists
      if old_project_role
        @granted_role = GrantedRole.update(old_project_role.id, { :role_type_id => role_type.id })
        # otherwise create a new role
      else
        if(role_type.name == 'administrator')
          @granted_role = GrantedRole.create(:user => @user, :role_type => role_type)
          project_reqs = ProjectUserRequest.find_all_by_user_id(@user.id)
          if project_reqs
            project_reqs.each do |project_req|
              ProjectUserRequest.update(project_req.id, :status => ProjectUserRequest.complete, :updator => current_user)
            end
          end
        else
          @granted_role = GrantedRole.create(:user => @user, :role_type => role_type, :project => project)
          project_req = ProjectUserRequest.find_by_user_id_and_project_id(@user.id, project.id)
          ProjectUserRequest.update(project_req.id, :status => ProjectUserRequest.complete, :updator => current_user) if project_req
        end
      end
      flash[:notice] = "New role '#{role_type.name}' granted to user #{@user.login}."
    end



    respond_to do |format|
      format.html { redirect_to user_granted_roles_path(@user) }
      format.js
    end

  end

  #TODO ensure that user cannot delete permissions they shouldn't be able to delete
  def destroy
    user = User.find(params[:user_id])
    @deleted_role = GrantedRole.find(params[:id])
    project = @deleted_role.project

    if(!is_admin?)
      current_user_role = current_user.granted_roles.find_by_project_id(project.id)
    else
      current_user_role = nil
    end
    current_user_rank = get_current_user_rank(current_user_role)

    # don't allow user to remove their own privileges
    if(current_user.id == user.id)
      flash[:error] = "Role not removed. You cannot remove your own privileges."
      # user must have at least rank of at least manager on current project to grant roles
    elsif current_user_rank < RoleType.find_by_name('manager').rank
      flash[:error] = "Role not removed. You must be a project manager or above to remove roles on a project."
    # users role on the specified project must be greater than the role they are deleting
    elsif !is_admin? && current_user_rank <= @deleted_role.role_type.rank
      flash[:error] = "Role not removed. Your role on this project must be greater than that of the role you are removing."
    # deleting of role is successful
    else
      GrantedRole.destroy(params[:id])
      flash[:notice] = "Role deleted for user #{user.login}"
    end

    respond_to do |format|
      format.html { redirect_to user_granted_roles_path(user) }
      format.js
    end
  end

  private

  def get_current_user_rank(role)
    # nil return value for role query means user has no roles
    if is_admin?
      rank = RoleType.find_by_name("administrator").rank
    elsif role.nil?
      rank = 0
    else
      rank = role.role_type.rank
    end
    rank
  end
end
