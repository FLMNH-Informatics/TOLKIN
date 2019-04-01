
require "restful/responder"
class ProjectsController < ApplicationController

  include Restful::Responder

  # index, show
  #before_filter :requires_logged_in, :only => [ :index ]
#  before_filter :requires_project_guest, :only => [ :show ]
  before_filter :requires_project_manager, :only => [ :new, :create, :edit, :update ]
  skip_before_filter :requires_any_guest, :only => [ :index, :show, :license_info ]

  def index
    @projects =
      current_user.public_user? ?
          Project.where("public = TRUE") :
          current_user.projects #Project.permitted_for(current_user, to: 'view').all     # cant figure this stuff out



        #passkey.unlock(Project)

#    # admin sees all projects
#    if is_admin?
#      @projects = Project.all
#    # non-admins see only their projects
#    else
#      #mi0437 : show projects with granted roles only once
#      @projects = Project.find_by_sql ["select * from projects where id in
#                                        (select project_id from granted_roles where user_id=?)", current_user.id]
#        #current_user.projects
#      @pending_project_requests = current_user.pending_project_requests
#    end
#    # if user only has one project then redirect to that project start page
#    if current_user.projects.count == 1 && !(@pending_project_requests.try(:size).try(:>, 0) )
#      redirect_to tree_view_project_taxa_path(current_user.projects.first.id)
#    end
    render 'index'
  end

  def show

    session[:project_id] = params[:id]
    @taxa = passkey.unlock(Taxon)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(params[:project])
    @user = User.find(session[:user_id])

    save_success = @project.save
    debugger
    if save_success && !@user.is_admin?
      GrantedRole.create(:user => @user, :project => @project, :role_type => RoleType.find_by_name('manager'))
  end

    if save_success
      redirect_to projects_path
    else
      render :new
    end
  end

  def edit

    @project = passkey.unlock(Project).find(params[:id])
    #only let them edit their own licenses
    @license = @project.public_license == nil || @project.public_license_id < 5 ?  PublicLicense.new  : @project.public_license

    respond_to{|format| format.html { render 'edit', layout: request.xhr? ? false : 'application' } }

  end

  def license_info
    lic = PublicLicense.where(:id => params[:id]).first
    render :json => {:name => lic.name, :label => lic.label, :desc => lic.description, :url => lic.url}
  end
#  def collections
#    respond_to_index_request(@current_project.collections)
#  end

  def update

    @project = Project.find(params[:id])
    @project.public = params[:project][:public] == 'on' ?  true : false
   # if @project.public == true
    case  params[:project][:public_license_id].to_i
      when 0
        #new license def
        lic = PublicLicense.new
        lic.name = params[:public_license][:name]
        lic.label = params[:public_license][:label]
        lic.description = params[:public_license][:description]
        lic.url = params[:public_license][:url]
        lic.project_id = params[:id]
        lic.save
        @project.public_license_id = lic.id

      when 1,2,3,4
        @project.public_license_id = params[:project][:public_license_id].to_i

      else
        lic = PublicLicense.where(:id => params[:project][:public_license_id].to_i).first
        lic.name = params[:public_license][:name]
        lic.label = params[:public_license][:label]
        lic.description = params[:public_license][:description]
        lic.url = params[:public_license][:url]
        lic.save

    end
=begin
    if params[:project][:public_license_id].to_i == 0

        lic = PublicLicense.new
        lic.name = params[:public_license][:name]
        lic.label = params[:public_license][:label]
        lic.description = params[:public_license][:description]
        lic.url = params[:public_license][:url]
        lic.project_id = params[:id]
        lic.save
        @project.public_license_id = lic.id
      end

      if params[:project][:public_license_id].to_i > 4
        lic = PublicLicense.where(:id => params[:project][:public_license_id].to_i).first
        lic.name = params[:public_license][:name]
        lic.label = params[:public_license][:label]
        lic.description = params[:public_license][:description]
        lic.url = params[:public_license][:url]
        lic.save
      end
=end
   # end

    #@project.update_attributes(params[:project])
    @project.save
    #redirect_to project_path(session[:project_id])

    head :ok
  end


end
