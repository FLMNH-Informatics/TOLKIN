class TagsController < ApplicationController
  include AuthenticatedSystem
  #layout 'standard', :except => :new

  before_filter :requires_logged_in

  #auto_complete_for :tag, :name,#:conditions =>[ "LOWER(name) LIKE ? and #{Tag.table_name}.id = #{Tagging.table_name}.tag_id and #{Tagging.table_name}.user_id= #{@current_user.id}", '%' + params[:tag_name] + '%'  ],:joins => "Taggings",:select =>"DISTINCT(name), #{Tag.table_name}.id"

  def index
    list
    render :action => 'list' #cloud
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  #verify :method => :post, :only => [ :destroy, :create, :update ],
  #       :redirect_to => { :action => :list }

  def list
    @tags = Tag.counts(:conditions=>["taggings.user_id= #{@current_user.id}"], :order => "tags.id")
    #super(passkey.unlock(Tag))
    #@tags = @current_user.tags.find(:all,:select=>"DISTINCT(name),tags.id")
  end

  def show
    @tag = Tag.find(params[:id])
    @taggings = nil
    if !@tag.nil? && !@tag.taggings.nil?
      @taggings = @tag.taggings.paginate(:all,:page => params[:page],:per_page => 20,:conditions=>["user_id=?",@current_user.id])
    end
  end

  def new
    render  :layout=> false
  end

  def create
    item_array = Array.new
    if(params[:url]=="model")
      if params[:ids]
        params[:ids].each do |id|
          item_array << params[:model].constantize.find(:first, :conditions=>["id=?", id])
        end
      end
    else
      temp = Bookmark.create!(:url => params[:url])
      item_array << temp
    end
    item_array.each do |item|
      #params[:tag][:name].split.each do |name|
        tag = Tag.find_or_create_by_name(params[:tag][:name])
        tag.taggings.create!(:user => @current_user, :tag => tag, :taggable_id => item.id, :taggable_type => item.class.to_s)
     # end
    end
    flash[:notice] = "Added tags successfully"
  end

  def edit

  end

  def update
  end

  def destroy
    tag_name = Tag.find(params[:id]).name
    @current_user.tags.find(params[:id]).taggings.delete_all
    flash[:notice] = "Tag successfully deleted." 
    redirect_to tags_path()
  end

  def auto_complete_for_tag_name
    #@items = Tag.counts(:conditions=>["taggings.user_id= #{@current_user.id} and LOWER(name) LIKE '%#{params[:tag][:name].downcase}%'"],:order=>"name ASC",:limit=> 10)
    @items = Tag.counts(:conditions=>["taggings.user_id= #{@current_user.id} and LOWER(name) LIKE '%#{params[:value].downcase}%'"],:order=>"name ASC",:limit=> 10)
    if params[:list]=="true"
      render :inline => "<%= auto_complete_result @items, 'name',nil %>" ,:layout=>false
    else
      render :inline => "<%= auto_complete_result @items, 'name',nil,'a' %>" ,:layout=>false  #this is a custom method to implement the hyperlinks coming in the result list
    end
  end
end
