class ImagesController < ApplicationController
  include SetMimeType
  skip_before_filter :requires_any_guest
  ##TODO make sure appropruate filters are applied at a later point
  #  before_filter :requires_project_guest, :only => [ :index, :show ]
  #  before_filter :requires_project_updater, :only => [ :new, :create, :edit, :update ]
  #  before_filter :requires_project_manager, :only => [ :destroy ]
  before_filter :set_attachment_type
  
  def index
    @images = Image.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @images }
      format.js
    end
  end

  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image }
    end
  end

  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @image }
      format.js
    end
  end

  def edit
    @image = Image.find(params[:id])
  end

  def swfupload
    params[:image] = {}
    params[:image][:attachment] = params[:Filedata]
    begin
    @image = Image.create!(params[:image])
    rescue => e
      debugger
      'hello'
    end
#    @image = Image.new(uploaded_data: params[:Filedata])
    #FIXME: really need to add user authentication for swfupload
    Image.transaction do |image|
      # swfupload action set in routes.rb
      @linking_object = (klass = params[:options][:image_type].constantize).find(params[:options][:id], klass.new.kind_of?(Record) ? { bypass_auth: true } : {}) # bypass_auth bad, but necessary for now
      @linking_object.images << @image
    end
    render json: @image.to_json()
  end

#    def create
#     # Standard, one-at-a-time, upload action
#    @image = Image.create!(params[:image])
#
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @image }
#      format.js
#    end
#  end


  def create
    Image.transaction do
      file = {}
      file[:attachment] = params[:image][:uploaded_data]
 
      @image = Image.create!(file)
      if params[:options][:image_type] == "Morphology::StateCoding"
        if params[:options][:id].blank? || params[:options][:id].nil?
          @old_object = nil
          @linking_object = Morphology::StateCoding.create!(:character_id => params[:options][:chr_id], :otu_id => params[:options][:otu_id], :status => "incomplete")
        else
          @old_object = Morphology::StateCoding.find(params[:options][:id])
          @linking_object = @old_object.create_clone(:matrix_id => nil)
        end
        @changeset = Matrix::Changeset.find(params[:options][:changeset_id])
        @changeset.items.create! :change_type => ChangeTypes::MODIFY, :old_version => @old_object, :new_version => @linking_object
      else
        @linking_object = params[:options][:image_type].constantize.find(params[:options][:id])
      end
      @linking_object.images << @image
    end

    @image_link = @image.image_joins.find_by_object_id_and_object_type(@linking_object.id, @linking_object.class.to_s)
    params.delete('image')

    flash[:notice] = 'Image was successfully created.'
    respond_to do |format|
      format.html { redirect_to :back }
      #        responds_to_parent do
      #          render :update do |page|
      #            page << "$('upload_frame').writeAttribute('data-image', '#{@image.to_json}');"
      #            page << "$('upload_frame').onchange();"
      #            page
      #          end
      #        end
      format.xml  { render :xml => @image, :status => :created, :location => @image }
      format.js {
        responds_to_parent do
          render :update do |page|
            if(params[:options][:image_type] == "Morphology::ChrState")
              page.insert_html :bottom, "imagesdiv_chr_state_#{@linking_object.id}", :partial => 'shared/image', :object => @image_link
              page["new_chr_state_image_div"].hide
            else
              page.insert_html :bottom, :imagesdiv, :partial => 'shared/image', :object => @image_link
              page["newimagediv"].hide
            end
            page.replace_html :notice, flash[:notice]
            flash.discard
          end
        end
      }
    end
  rescue => e
    debugger
    respond_to do |format|
      format.html { render :action => "new" }
      format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
      format.js do
        flash.now[:error] = "Error encountered while saving image: #{e.message}"
        #        responds_to_parent { render "errors/flash_message" }
      end
    end
  end

  def update
    @image = @current_project.images.find(params[:id])
    @image.update_attributes!(params[:image])
    respond_to do |format|
      format.json { render json: @image }
    end
  end


  def destroy
    Image.find(params[:id]).destroy

    respond_to do |format|
      format.html { redirect_to(request.referer) }
      format.xml  { head :ok }
      format.js
    end
  end

#  def destroy_link
#    ImageLink.find(params[:link_id])
#  end
end
