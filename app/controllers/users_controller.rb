class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  #layout 'standard'
  layout 'application'

  before_filter :not_logged_in_required, :only => [ :new, :create]
  skip_before_filter :requires_any_guest, :only => [ :new, :create ]
  #TODO filter needs to be included to keep users from looking at other users
  before_filter :requires_logged_in, :only => [ :show, :edit, :update]
  before_filter :requires_any_manager, :only => [ :index, :search, :add_user_to_project ]
  before_filter :requires_admin, :only => [ :destroy, :enable ]
  before_filter :get_all_projects, :only => [:new, :create]

  skip_before_filter :requires_any_guest, :only => [:new, :create, :activate]

  def index
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

  #This show action only allows users to view their own profile
  def show
    debugger
    @user = current_user
  end

  # render new.rhtml
  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    #logout_keeping_session!
    #hack to overcome the problem of assinging params, need to see this in more details
#    person = Person.new(params[:user][:person])
    params[:user][:person] = nil
    @user = User.new(params[:user])
#    @user.person = person
    @user.enabled = false
    if validate_recap(params, @user.errors) && @user.save
      if params[:project_ids]
        params[:project_ids].each do |proj_id|
          project = Project.find(proj_id)
          begin
            ProjectUserRequest.create!(:project => project, :user => @user, :status => "pending" )
          rescue => exception
            log_error exception
          end
        end
      end
      flash[:notice] = "Thanks for signing up!.You will shortly recieve an email for your identity verification."
      redirect_back_or_default('/')
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again."
      render :action => 'new'
    end
  rescue => exception
    log_error exception
    flash[:error] = "We had the following problems creating your account:<br />#{exception}<br/>Please check that the email address you have provided us is valid."
    render :action => 'new'
  end

  def update
    @user = User.find(params[:id])
    @user.attributes= params[:user]
    if @user.save
      flash[:notice] = "User updated"
      redirect_to user_path(@user)
    else
      respond_to do |format|
        format.html { render :action => :show}
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, false)
      flash[:notice] = "User disabled"
    else
      flash[:error] = "There was a problem disabling this user."
    end
    redirect_to :back
  end

  def enable
    debugger
    @user = User.find(params[:id])
    if @user.update_attribute(:enabled, true)
      flash[:notice] = "User enabled"
    else
      flash[:error] = "There was a problem enabling this user."
    end
    redirect_to :back
  end

  def activate
    #logout_keeping_session!
    debugger
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.update_attribute(:enabled, true)
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  # currently just used for getting ajax response for adding user to a project
  def search
    @first_name = params[:user][:first_name]
    @last_name = params[:user][:last_name]
    @users = User.find(:all, :include => :person, :conditions => ['"v_users".first_name ILIKE ? AND "v_users".last_name ILIKE ?', @first_name, @last_name ] )
    if is_admin?
      @projects = Project.all
    else
      # get all projects for which current user has role of manager
      @projects = Project.find_by_sql ["select * from projects where id in
                                        (select project_id from granted_roles where user_id=? and role_type_id=
                                        (select id from role_types where name='manager'))", current_user.id]
    end

    max_rank = current_user.role_types.maximum('rank')
    if(!is_admin?)
      @roles = RoleType.find(:all, :conditions => [ "rank < ?", max_rank ])
    else
      @roles = RoleType.all
    end

    respond_to do |format|
      format.js
    end
  end

  def add_user_to_project
    @user = User.new
    render :partial => 'add_user_to_project_window'
  end

  private
  def get_all_projects
   
    @projects = Project.find(:all)
  end
end
