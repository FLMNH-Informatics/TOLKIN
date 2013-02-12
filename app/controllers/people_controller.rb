class PeopleController < ApplicationController
  include CitationsHelper
  include Restful::Responder

  before_filter :params_to_hash
  before_filter :requires_selected_project
  before_filter :requires_project_guest, :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :create, :edit, :update ]
  before_filter :requires_project_manager, :only => [ :destroy ]
  rescue_from ActiveRecord::RecordNotFound, :with => :redirect_if_not_found

  def index

    params.include?(:limit)   || params[:limit] = 20
    params[:page] ? (params[:offset] =  (params[:limit].to_i * params[:page].to_i - 1)) : (!params.include?(:offset)? (params[:offset] = 0) : '')
    super current_project.people
#    validate_text_params && parse_text_params
#    @requested = Person.find_by_sql([%{
#      SELECT p.*
#      FROM people p
#        LEFT JOIN user_additional_info u ON ( p.id = u.person_id )
#        LEFT JOIN granted_roles gr ON (u.id = gr.user_id AND gr.project_id = ?)
#        LEFT JOIN role_types rt ON (rt.id = gr.role_type_id AND rank > 1 AND rank < 4)
#        WHERE (
#          p.project_id = ? OR
#          rt.id IS NOT NULL
#        )
#      ORDER BY p.last_name ASC, p.first_name ASC
#    }, params[:project_id], params[:project_id]])
#    @people = @requested
#    respond_to do |format|
#      format.json { render json: %{{ "requested": #{@requested.to_json(parse_formatter_params_for_people)} }} }
#      format.xml  { render :xml  => @requested.to_json(parse_formatter_params_for_people) }
#      format.html { @people = @people.paginate(:page => params[:page],:per_page => 20, :order=>:last_name) }
#    end
  end

  def show
    @person = Person.find(params[:id])
    respond_to do |format|
      format.html {redirect_to :action=> "edit"}
      format.xml  { render :xml => @person }
    end
  end

  def new
    @person = Person.new
  end

  def edit
    @person = Person.find(params[:id])
  end


  def create
    @person =  ( !params[:person][:name].nil? &&
        Person.new(Author.extract_firstlast_names(params[:person][:name],' '))) ||
      Person.new(params[:person])
    #TODO : USE @current_user.projects.Person.new ?? something like that to avoid these lines
    @person.user_id = @current_user.id
    @person.project_id = params[:project_id]
    respond_to do |format|
      if @person.save
        flash[:notice] = 'Author was successfully created.'
        format.html { redirect_to(project_people_path(params[:project_id])) }
        format.xml  { render :xml => @person, :status => :created, :location => @person }
        format.js
      else
        flash.new[:error] ="Could not create author."
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    Person.find(params[:id]).update_attributes(params[:person])
    respond_to do |format|
      format.html do
        flash[:notice] = 'Author was successfully updated.'
        redirect_to(project_people_path(params[:project_id]))
      end
      format.xml  { head :ok }
    end
  end

  def destroy
    @person = Person.find(params[:id])
    @person.destroy
    respond_to do |format|
      format.html do
        flash[:notice] = (!@person.errors.empty? && @person.errors.full_messages.join(', ')) || "Record Successfully delted"
        redirect_to(project_people_url(params[:project_id]))
      end
      format.xml  { head :ok }
    end
  end

  protected
  def redirect_if_not_found
    debugger
    flash[:notice] = "Record Not Found"
    redirect_to(project_people_url(params[:project_id]))
  end
end
