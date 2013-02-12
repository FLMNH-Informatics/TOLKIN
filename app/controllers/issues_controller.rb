class IssuesController < ApplicationController
  before_filter :requires_project_guest,   :only => [ :index, :show ]
  before_filter :requires_project_updater, :only => [ :new, :create]
  
  before_filter :requires_admin, :except=> [:new, :create]
  #rescue_from ActiveRecord::ActiveRecordError, :with => report_error
  
  def index
    fill_issues_list_attributes_for_index_listing
    @issues = Issue.paginate :page => params[:page], :per_page => 20, :order => 'updated_at'
  end
  
  def new
    @issue = Issue.new
    render "new", :layout=>false
  end
  
  def create
    @issue = Issue.new(params[:issue])
    @issue.user_id = @current_user.id
    if @issue.save
      respond_to do |format|
        format.html {render "create", :layout=>false}
        format.xml  { render :xml => @issue }
      end
    else
      respond_to do |format|
        format.html {render "new", :layout=>false}
        format.xml  { render :xml => @issue }
      end
    end
  end
  private
  def fill_issues_list_attributes_for_index_listing
    @attributes_to_show = [ :description, :status, :user, :email, :created_at, :updated_at ]
    @attribute_display_properties = {
      :description      => { :label => 'Description' },
      :status           => { :label => 'Status'},
      :user => { :label => 'User',
        :display_attribute => 'login'
      },
      :email => {:label=> 'Email'},
      :created_at       => { :label => 'Created Date'},
      :updated_at       => { :label => 'Updated Date'}
    }
  end
end
