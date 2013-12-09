class Admin::UsersController < ApplicationController

  include AuthenticatedSystem

  before_filter :requires_project_manager

  def index
=begin
    @users =
     (current_user.is_admin? ? User :  User.with_roles_in_project(current_project)).
       order([:last_name, :first_name ]).
       select([:user_id, :first_name, :last_name, :username, :email, :enabled ]).
       all.
       paginate(
         :page => params[:page],
         :per_page => 20
       )
=end
    @users = (current_user.is_admin? ? User : params.has_key?(:id) ?  User.with_roles_in_project(Project.find(params[:id]))  : User.with_roles_in_project(current_project) )
    .order([:last_name, :first_name ]).select([:user_id, :first_name, :last_name, :username, :email, :enabled ])
    .paginate(:page => params[:page], :per_page => 20)

     render :partial => 'users_table' if request.xml_http_request?

  end

  def new

    @projects = is_admin? ? Basic::Project.all : projects_with_manager_rights
    @roles = RoleType.where("name <> 'administrator'")
  end

  def create
=begin
    nuser = {
        :first_name => params[:first_name],
        :last_name => params[:last_name],
        :username => params[:username],
        :email => params[:email],
        :initials => '',
        :institution => params[:institution],
        :owner_user_rtid => 10,
        :owner_record_rtid => 1,
        :owner_graph_rtid => 12,
        :owner_permission_set_rtid => 11,
        :creator_rtid => 10,
        :created_at => Time.now,
        :updater_rtid => 10,
        :updated_at => Time.now,
        :enabled => true,
        :password => :params[:password],
        :password_confirmation => params[:password_confirmation]
    }
    u = Basic::User.new(nuser)
    u.save!
=end
    user = Basic::User.find_by_sql %{ INSERT INTO users
                                (first_name,last_name,username,email,initials,institution,owner_user_rtid,owner_record_rtid,owner_graph_rtid,owner_permission_set_rtid,creator_rtid,
                                created_at,updater_rtid,updated_at,enabled,password)
                               VALUES ('#{params[:first_name]}','#{params[:last_name]}','#{params[:username]}','#{params[:email]}','',
                                '#{params[:institution]}',10,1,12,11,10,now(),10,now(),true,'#{params[:password]}') RETURNING user_id }
    u = Basic::User.find(user[0][:user_id])

    u.owner_record_rtid = u.rtid

    u.save!
    #now add user to selected projects
    params[:projects].each do |key,val|
      if val.has_key?(:member) && val[:member] == 'true'
        add_user_to_project(key, u.user_id, val[:role])
      end
    end

    redirect_to :action => :index
  end

  def add_user
    params[:projects].each do |key,val|
      add_user_to_project key, params[:user_id], val
    end

    redirect_to :action => :index
  end

  def roles
    ids = []

    #get users roles for projects that user shares with manager/admin person
    @user = Basic::User.find(params[:id])
    @user_projects = @user.projects
    @user_projects.each do |userp|
       ids << userp.id
    end
    @projects_available = current_user.is_admin? ? Basic::Project.where('project_id NOT IN ('+ids.join(',')+')') : current_user.projects.where('project_id NOT IN ('+ids.join(',')+')')

  end

  def assign

    params[:project].each do |key,has|
      add_user_to_project(key.to_i, params[:id], has[:role]) if has.has_key?(:member) && has[:member] == 'true'
    end
    redirect_to :action => :roles
  end

  def unassign
    Basic::GrantedRole.where("user_id = ? AND project_id = ?", params[:id], params[:project_id]).destroy_all
    redirect_to :action => :roles
  end
  private

  def projects_with_manager_rights
    Basic::Project.find_by_sql %{ SELECT p.* FROM projects p RIGHT JOIN granted_roles g ON g.project_id = p.project_id LEFT JOIN users u ON u.user_id = g.user_id WHERE u.user_id = #{current_user.id} AND role_type_id = 3 }
  end

  def add_user_to_project(project, user, role)
    g = GrantedRole.new
    g.user_id = user.to_i
    g.project_id = project.to_i
    g.role_type_id = role.to_i
    g.save!

    p = Basic::Project.find(project.to_i)

    perm = Basic::RoleMemberUser.new
    perm.owner_user_rtid = 10
    perm.owner_record_rtid = 1
    perm.owner_graph_rtid = p.rtid
    perm.owner_permission_set_rtid = p.owner_permission_set_rtid
    perm.creator_rtid = 10
    perm.created_at =  Time.now
    perm.updater_rtid = 10
    perm.updated_at = Time.now

    rtypes = { 1 => 'Guest', 2 => 'Updater', 3 => 'Manager' }
    ro = Basic::Role.where("owner_graph_rtid = ? AND label = ?", p.rtid, rtypes[role.to_i])

    perm.subj_rtid = ro.first.rtid
    perm.prop_rtid = 8
    perm.obj_rtid = Basic::User.find(user.to_i).rtid

    perm.save!

    perm.owner_record_rtid = perm.rtid

    perm.save!

  end

end