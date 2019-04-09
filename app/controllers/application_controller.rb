# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

#TODO if we up rails version this file should be changed from application.rb to
# application_controller.rb

class ApplicationController < ActionController::Base
  include ReCaptcha::AppHelper
  include SessionStore::Accessors
  include Authorized::ActionController::ProvidesPasskey
  include Publifier

  config.relative_url_root = ""

  after_filter :set_last_uri
  #TODO need to check how many links are broken

  clear_helpers # get rid of helper :all from ActionController::Base
  helper( 'prototype', 'form', 'admin', 'application', 'characters', 'chr_groups', 'citations', 'forms', 'granted_roles',
    'images', 'marked_record', 'matrices', 'user_panel', 'nexus_datasets', 'otu_groups', 'otus', 'primers', 'projects',
    'shared', 'shopping_cart', 'sprockets', 'tabs', 'tags', 'users', 'widgets', 'windows' , 'current_selection', 'publications', 'publishers')
  helper AutoCompleteMacrosHelper


  before_filter :default_response_headers
  before_filter :masquerade_handler
  before_filter :put_relative_url_root_in_params
  before_filter :initialize_variables
  before_filter :set_user_signature
  before_filter :update_selected_project
  before_filter :init_interact_mode
  before_filter :session_history_pre_filter
  #before_filter :set_public_user
  #before_filter :requires_any_guest
  after_filter :session_history_post_filter

  include AuthenticatedSystem
  #include ExceptionNotifiable

  #TODO move emails to initializers file
  #ExceptionNotifier.exception_recipients = ExceptionRecipients

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  #filter_parameter_logging :password

  # make page parameters fully modifiable, allows for the recovery of state during
  # controller chaining

  def default_response_headers
    headers['Vary'] = 'Accept'
  end

  def masquerade_handler
    if params[:masquerade]
      session[:masquerade] = params[:masquerade].to_b
    end
    if params[:masquerade_as]
      session[:masquerade_as] = params[:masquerade_as]
    end
    if session[:masquerade] && current_user.is_admin?
      mask = User.where(username: session[:masquerade_as]).first
      @current_user = mask
      passkey.user(mask)
    end
  end

  def params
    @parameters ||= super
  end

  def init_interact_mode
    if current_user.public_user?
      self.interact_mode = 'browse'
    else 
      params[:interact_mode] ? 
        (self.interact_mode = params[:interact_mode]) :
        (interact_mode || self.interact_mode = 'browse')
    end
  end

  def optional_matrix_resource_url(link_params)
    link_params.delete(:matrix_id) if link_params[:matrix_id].nil?
    url_for(link_params)
  end

  # allows for redirects using post, put, and delete methods
  def redirect_with_request(parameters)
    controller_name = parameters[:controller]
    controller = "#{controller_name.camelize}Controller".constantize
    request.parameters.reject! { true }
    request.parameters.merge! parameters
    controller.process(request, response)
    if response.redirected_to
      @performed_redirect = true
    else
      @performed_render = true
    end
  end

  def get_help_file
    send_file(RAILS_ROOT + '/private/files/help/tolkin_guide.doc')
  end
  private

  def initialize_variables
    @javascript_includes = [ ] # array to be filled by page elements with names of needed javascript files
    session[:params_stack] ||= Sessions::ParameterStack.new # don't use this, we should get rid of this
    session['interaction_mode'] ||= 'browse'    
    if(current_project)
      #@session_vars ||= SessionVariables.for_session_and_project(session, current_project)
#      session[:projects][current_project] = { } unless session[:projects]
#        session[:projects][current_project] = { } unless session[:projects][current_project]
#        session[:projects][current_project][:cart] = { } unless session[:projects][current_project][:cart]
        session[:projects] ||= {}
        session[:projects][current_project.id.to_s] ||= {}
        session[:projects][current_project.id.to_s][:cart] ||= {}
        session[:projects][current_project.id.to_s][:cart][:saved] = { } unless session[:projects][current_project.id.to_s][:cart][:saved]
        session[:projects][current_project.id.to_s][:cart][:saved] = {:Taxon => {} , :Collection => {}, :Otu => {}} unless session[:projects][current_project.id.to_s][:cart][:saved][:Taxon]
        
       
      #@session_vars.cart_for_project(@current_project).items
      #@session_vars.interaction_mode
    end

  end
  #set public user
  def set_public_user
     current_user = User.find_by_username('public') if current_user == nil
  end

  def set_last_uri
    # This function sets the last visited page as a session variable
    # Can be used in any view to generate the Back Link

    #FIXME: Does not work if the page is refreshed
    session[:last_uri] = request.fullpath
  end

  # create a new signature observer if user is logged in but no signature observer is currently initialized
  def set_user_signature
    UserSignature.instance.user = current_user if UserSignature.instance.user != current_user # convenient but not necessarily foolproof - only works if controller is never interrupted when running
  end

  def can_delete?
    need_perm_lvl = 3
    ids = [*(params[:id] || params[:ids] || params[:data])]
    ids.all? do |id|
      record = params[:controller].classify.constantize.find(id)
      check_record_permission record, need_perm_lvl
    end
  end

  def can_update?
    need_perm_lvl = 2
    # TODO: FINISH ME - NOT USED ANYWHERE
  end

  #TODO make req_permissions system compatible and dependent on granted roles system
  def check_record_permission(record = params[:id] ? params[:controller].classify.constantize.find(params[:id]) : nil, need_perm_lvl = 2)
    if current_user.is_manager?(current_project)
      true
    elsif current_user.is_updater?(current_project)
      if record.respond_to?(:creator) && record.creator == current_user
        true
      else
        obj_perm = record.respond_to?(:recpermission) ? record.recpermission.name.downcase : 'edit'
        if obj_perm == 'edit' and need_perm_lvl <= 2
          true
        elsif obj_perm == 'delete' and need_perm_lvl <= 3
          true
        else
          false
        end
      end
    else
      false
    end
#    if (
#      obj.creator_id != @current_user.try(:id) &&
#      (
#        (obj.recpermission.name.downcase == Recpermission.edit && req_permission == Recpermission.delete) ||
#        (obj.recpermission.name.downcase == Recpermission.delete &&
#          (req_permission == Recpermission.edit || req_permission == Recpermission.delete) )
#      )
#    )
  end

  # if stored selected project id is old compared to project id passed in params, update it
  def update_selected_project
    if params[:project_id] && params[:project_id] != session[:project_id]
      session[:project_id] = params[:project_id]
    end
    after_update_selected_project if params[:project_id]
  end

  def after_update_selected_project
    ProjectStamper.instance.project = current_project # convenient but not necessarily foolproof - only works if controller is never interrupted when running
    PermissionSetStamper.instance.project = current_project
    @session_vars = SessionVariables.for_session_and_project(session, @current_project)
  end

#  FIXME dont think its being used anymore, was used prev for generic search but not anymore
#  def advanced_search(include_columns)
#    searchArr = Array.new
#    if !params[:model_type].nil?
#      col_time_hash = Hash.new
#      temp = Array.new
#      params[params[:model_type]].each do |column_name, value|
#        if(!params[params[:model_type]+"_"+column_name+"_time"].nil?)
#          col_time_hash[params[:model_type]+"_"+column_name+"_time"] =  params[params[:model_type]+"_"+column_name+"_time"]
#        end
#      end
#      temp = col_time_hash.sort {|x,y| x[1]<=> y[1]} #sorts by the time value
#      searchArr[0] = ""
#      i=0
#      temp.each do |name_val_pair|  #and array of two elements
#        i=i+1
#        searchArr[0] = searchArr[0] + name_val_pair[0].chomp("_time").reverse.chomp((params[:model_type]+"_").reverse).reverse + " ILIKE ? "
#        searchArr << "%" +params[params[:model_type]][name_val_pair[0].chomp("_time").reverse.chomp((params[:model_type]+"_").reverse).reverse] +"%"
#        if(i<temp.size)
#          searchArr[0] = searchArr[0] + params[name_val_pair[0].chomp("_time")]["bin_op"] + " "
#        end
#      end
#      results = params[:model_type].classify.constantize.find(:all, :conditions => searchArr, :include => include_columns)
#    end
#    results
#  end

#  def current_project
#    if !params[:project_id].nil?
#      @current_project ||= ( Project.find(params[:project_id]) || false)
#    else
#      @current_project = nil
#    end
#  end

  # use this method when exceptions are caught early, as hoptoad-notifier won't
  # intercept with caught exceptions
  def log_error(exception)
    logger.error exception.message
    exception.backtrace.each do |trace_line|
      logger.error trace_line
    end
  end

  def rescue_action exception
    debugger unless exception.class == ActionController::RoutingError # dont stop at debugger when images cannot be found
    case exception
    when ActiveRecord::StatementInvalid
      if exception.to_s =~ /violates foreign key constraint "\w+?" on table "(\w+?)"/
        @text = "Record to delete still being referenced from '#{$1}'"
        @status = :bad_request
      else
        log_error exception
        @text = "An error has occurred: #{exception.message}"
        @status = :internal_server_error
      end
    end
    respond_to do |format|
      case exception
      when ActiveRecord::StatementInvalid
        format.html { render :template => 'errors/exception' }
      when ActiveRecord::RecordInvalid
        format.js   { flash.now[:error] = "#{exception.message}"; render "errors/flash_message"}
        format.html { render 'errors/record_not_found' }
      when ActiveRecord::RecordNotFound
        format.js   { render :text => "Record not found", :status => :not_found }
        format.html { render 'errors/record_not_found' }
      when ActiveRecord::StatementInvalid
        format.js   { render :text => @text, :status => @status}
      when ActionController::RoutingError
        render :template => 'errors/routing'
      when Exception::HasChildren
        format.js   { render :json => exception, :status => :bad_request }
      when RuntimeError
        format.js   { render :text => "An error has occurred: #{exception.message}", :status => :internal_server_error }
        format.html { render :template => 'errors/exception' }
      else
        log_error exception
        format.js   { render :text => "An error has occurred: #{exception.message}", :status => :internal_server_error }
        format.html { render :template => 'errors/exception' }
      end
    end
  end

  def session_history_pre_filter
    # TODO: this is misbehaving in Rails 3.  Fix this or get rid of it.
#    session[:history] ||= [ { :controller => 'projects', :action => 'index' } ]
#    params[:controller] = (params[:controller][0,1] == "/") ? params[:controller].underscore : "/#{params[:controller].underscore}" # make sure controllers aren't taken to be inside current namespace when url generated
#    session[:history].pop if session[:history].last == params # don't show current location in the history yet
#    2.times { session[:history].pop } if params[:back] && session[:history][session[:history].size - 2].merge(:back => "true") == params
#    @referrer = url_for session[:history][session[:history].size - 1].merge(:back => "true") if session[:history]
  end

  def session_history_post_filter
# TODO: this is misbehaving in Rails 3.  Fix this or get rid of it.
#    if request.format.to_s == "text/html" && !response.location # record only non-ajax requests that are not being redirected
#      session[:history].push params
#      session[:history].shift if session[:history].size > 10
#    end
  end

  def put_relative_url_root_in_params
    #params[:path_prefix] = ActionController::AbstractRequest.relative_url_root
    #params[:path_prefix] = ActionController::Base.relative_url_root
    params[:path_prefix] = root_path[1..-2].blank? ? '' : root_path[0..-2] # HACK - probably a better way to get prefix
  end

  #exorcize the evil of HashWithIndifferentAccess
  def params_to_hash
    @parameters = params.to_hash.symbolize_keys
  end
end


#making a list of all session objects used except for the ones used in different plugins
#session[:permission_denied] -- this is to be shared among all the controllers. This is can be implemented more elegantly i guess.
