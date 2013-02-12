module AuthenticatedSystem
  protected

  def requires_logged_in
    logged_in? || (request.host.match(/localhost/) && redirect_to(login_path)) || redirect_to("http://tolkin.org")
  end

  def requires_project_guest
    requires_project_role('guest')
  end

  def requires_project_updater
    requires_project_role('updater')
  end

  def requires_project_manager
    requires_project_role('manager')
  end

  def requires_selected_project
    !params[:project_id].nil? || alert_select_project
  end

  def alert_select_project
    flash[:notice] = "You must select a project to access this feature."
    redirect_to projects_path
  end

  def requires_project_role(roleName)
    has_project_role?(roleName) || permission_denied
  end

  def requires_admin
    is_admin? || permission_denied
  end

  def requires_any_updater
    current_user.is_updater? || permission_denied
  end

  def requires_any_manager
    is_manager? || permission_denied
  end

  def requires_any_guest
    is_guest? || permission_denied
  end

  def has_project_role?(roleName)
    # user not authorized if not logged in
    return false if !logged_in?
    # admin is automatically authorized for everything
    return true if is_admin?

    # extract required rank num from required rank given
    required_rank = RoleType.find_by_name(roleName).rank

    # if project access required check user permissions for that project
    if params[:project_id] != nil
      project = Project.find(params[:project_id], bypass_auth: true)  # NOTE : MAY NOT WANT TO BYPASS FOR TOO LONG
      # find user role for this project by project id
      granted_role = current_user.granted_roles.find(:first, :conditions => ["project_id = ?", project.id])
      (return false) if granted_role.nil?
      user_rank = granted_role.role_type.rank

      # user rank should be at least that required for access
      return true if user_rank >= required_rank
      # if not trying to access project check permissions against highest of
      # all obtained by the user
    else
      return true if current_user.role_types.count > 0 &&
        current_user.role_types.maximum('rank') >= required_rank
    end

    # if no valid permissions found return false
    false
  end

  # allow administrators to perform any action, even if user usually has to be
  # logged out to perform action (e.g. signup, create new user)
  def not_logged_in_required
    debugger
    !logged_in? || is_manager? || permission_denied
  end

  def is_admin?
    return false if !logged_in?
    return true if current_user.role_types.where(name: 'administrator').any?
  end

  # method doesn't check if user is manager of current project or not
  # user must have any role with rank of at least manager to return true
  def is_manager?
    return false if !logged_in?

    if !current_user.role_types.empty?
      user_rank = current_user.role_types.maximum(:rank)
    # if user has no roles return false
    else
      return false
    end
    return true if user_rank >= RoleType.find_by_name('manager').rank
  end

  def is_guest?
    return false if !logged_in?
    current_user.role_types.empty? ? false : true
  end

  def logged_in?
    current_user == User.public_user ? false : true
#    current_user ? true : false
    #current_user != :false
  end

  # Accesses the current user from the session.  Set it to :false if login fails
  # so that future calls do not hit the database.
  def current_user
    #FIXME: don't leave set to nil, set to :false.  this is only a test for netzke
    @current_user ||= (login_from_session || login_from_basic_auth ||  (params[:public_user] = true && User.public_user) || login_from_cookie )
  end

  # Store the given user id in the session.
  def current_user=(new_user)
    session[:user_id] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
    @current_user = new_user || :false
  end

  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def redirect_to_login
    respond_to do |format|
      format.html do
        store_location
        # bypass flashing error message if user is at website home page
        if(request.request_uri != "/")
          flash[:error] = "You must be logged in to access this feature."
        end
        redirect_to new_session_path
      end
      format.xml do
        request_http_basic_authentication 'Web Password'
      end
    end
  end

  def permission_denied
    respond_to do |format|
      if (!is_admin?) && (request.request_uri == "/users/admin")
        format.js   { render :text => "404 Record not found", :status => :not_found }
        format.html { render 'errors/record_not_found' }
      else
        format.html do
          http_referer = session[:refer_to]
          if http_referer.nil?
            store_referer
            http_referer = session[:refer_to]
          end
          flash[:error] = "You don't have permission to complete that action."

          if http_referer == request.url
            session[:refer_to] = nil
            redirect_to root_path
          else
            redirect_to_referer_or_default(root_path)
          end
        end
        format.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "You don't have permission to complete this action.", :status => '401 Unauthorized'
        end
      end
    end
  end

  # Store the URI of the current request in the session.
  #
  # We can return to this location by calling #redirect_back_or_default.
  def store_location
    session[:return_to] = request.request_uri
  end

  def store_referer
    session[:refer_to] = request.env["HTTP_REFERER"]
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_to_referer_or_default(default)
    redirect_to(session[:refer_to] || default)
    session[:refer_to] = nil
  end

  # Inclusion hook to make #current_user and #logged_in?
  # available as ActionView helper methods.
  def self.included(base)
    base.send :helper_method, :current_user, :logged_in?, :is_admin?, :is_manager?
  end

  # Called from #current_user.  First attempt to login by the user id stored in the session.
  def login_from_session
    self.current_user = User.find(session[:user_id], bypass_auth: true) if session[:user_id] #&& User.find(session[:user_id])
  end

  # Called from #current_user.  Now, attempt to login by basic authentication information.
  def login_from_basic_auth
    authenticate_with_http_basic do |username, password|
      self.current_user = User.authenticate(username, password)
    end
  end

  # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
  def login_from_cookie
    user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      user.remember_me
      cookies[:auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
      self.current_user = user
    end
  end
end
