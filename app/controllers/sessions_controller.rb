# This controller handles the login/logout function of the site.
require 'my_session_module'
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  include MySessionModule
  #before_filter :not_logged_in_required, :only => [:new, :create]
  before_filter :requires_logged_in, :only => [ :destroy ]
  skip_before_filter :requires_any_guest, :only => [ :new, :create, :destroy]

  def new
    @present_captcha = true if check_or_create_log.present_captcha?
  end

  def create
    password_authentication(params[:login] || params[:username_or_email], params[:password])
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to :back
    #(request.host.match(/localhost/) && redirect_to(login_path)) || redirect_to("http://tolkin.org")
  end
   
  protected

  def password_authentication(login, password)
    user = User.authenticate(login, password) if (check_or_create_log.present_captcha? && validate_recap(params, NewSessionErrors.new) || !check_or_create_log.present_captcha?)
    if user.nil?
      failed_login("Login Failed, Please Try Again.")
      #elsif user.activated_at.blank?
      #  failed_login("Your account is not active, please check your email for the activation code.")
    elsif !user.enabled?# == false #alse not sure y this doesnt work as per wat i read it was supposed to work
      failed_login("Your account has been disabled.")
    else
      self.current_user = user
      successful_login
    end
  end
  
  private
  def check_or_create_log
    ip_log = IpLog.find(:first,:conditions=>["ip_addr = ?", request.remote_ip])
    ip_log = IpLog.create_log(request.remote_ip) if ip_log.nil?
    ip_log
  end
  def failed_login(message)
    check_or_create_log.increment!(:failed_logins)#increment_falied_login
    flash[:error] = message
    #render :action => 'new'
    redirect_to :action => :new
  end
   
  def successful_login
    check_or_create_log.reset_falied_login
    if params[:remember_me] == "1"
      self.current_user.remember_me
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end
    return_to = session[:return_to]
    if params[:redirect_to] == 'back'
      redirect_to :back
    elsif return_to.nil?
      #redirect_to [ ActionController::Base.relative_url_root, '/projects'].compact.join#user_path(self.current_user)
      redirect_to [ (root_path[1..-2].blank? ? '' : root_path[0..-2]), '/projects'].compact.join#user_path(self.current_user)
    else
      #redirect_to [ ActionController::Base.relative_url_root, return_to ].compact.join
      redirect_to [ (root_path[1..-2].blank? ? '' : root_path[0..-2]), return_to ].compact.join
    end
  end
end
