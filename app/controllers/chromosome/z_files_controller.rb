require 'zip/zip'

class Chromosome::ZFilesController < ApplicationController
  include Restful::Responder

  before_filter :requires_project_guest, :except => [:index,:show ]
  before_filter :requires_project_updater, :except => [ :index,:show]
  # before_filter :requires_project_manager, :except => [ ]

  def index
    @z_files = current_project.z_files
    query_params_provided? ||
        params.merge!(
            order: 'zvi_file_name',
            select: [ 'id', 'zvi_file_name', 'caption'],
            limit: 20
        )
    super(@z_files)
  end


  def new
    if params[:probe_id]
      @probes = current_project.probes.find(params[:probe_id])
      @z_file = current_project.z_files.new
    else
      @z_file = current_project.z_files.new
    end
    @z_file.uploaded_at_date = Time.now

    respond_to do |format|
      format.html {render :layout => false}
      format.xml { render({ :xml => @z_file })}
    end
  end

  def create
    @z_file = current_project.z_files.create(params[:z_file])
    if params[:probe_id] && params[:dyeId]
      #todo in the future use this to upload a z_file from the probes show page but possibly move into (a created) hybridizations controller/view
      probe = current_project.probes.find(params[:probe_id])
      @z_file.hybridizations << probe.hybridize(current_project.dyes.find(params[:dyeId]))
    end

    respond_to do |format|
      if @z_file.save
        format.html { redirect_to( project_chromosome_z_file_path(current_project, @z_file), :notice => 'ZVI File was successfully created.') }
        format.json  { render :json => @z_file}
      end
    end
  end

  def show
    super Chromosome::ZFile
  end

  def attach_image
    ##TODO After migration change zimages to images
    begin
      @z_file = Chromosome::ZFile.find(params[:id])
      msg = "Image attached."
      file = {}
      file[:attachment] = params[:chromosome_z_file].delete(:image)
      Chromosome::ZFile.transaction do
        @z_file.zimages << Image.create!(file.merge({:created_by => current_user.user_id}))
      end
    rescue => e
      log_error e
      msg = "Error, file was not a valid image:  " + e.to_s
    end
    flash[:notice] = msg
    redirect_to project_chromosome_z_file_path(current_project.project_id, params[:id])
  end

  def remove_image
    Image.find(params[:image_id]).destroy
    head :ok
  end


  def remove_hybridization
    msg = 'ok'
    begin
      Chromosome::ZFile.transaction do
        @z_file = current_project.z_files.find(params[:id])
        Chromosome::Hybridization.destroy(params[:hybridization_id])
      end
    rescue => e
      log_error e
      msg = "Error: " + e.to_s
    end
    flash[:notice] = msg unless request.xhr?
    respond_to do |format|
      format.json { render :json => {:msg => msg}}
      format.html { redirect_to project_chromosome_z_file_path(current_project.project_id, params[:id])}
    end
  end

  def create_hybridization
    begin
      Chromosome::ZFile.transaction do
        @z_file = current_project.z_files.find(params[:id])
        probes  = current_project.probes.find(params[:probeIds])
        dye     = current_project.dyes.find(params[:dyeId])
        probes.each{ |probe| @z_file.hybridizations << probe.hybridize(dye) }
      end
      respond_to{|format| format.json { render json: {:html => render_to_string("_z_file_probes_list.html.haml")}}}
    rescue => e
      log_error e
    end
  end

  def show_add_probe
    @probes = Chromosome::Probe.where(:project_id => current_project.project_id).order('value').limit(10)
    @project = current_project
    respond_to do |format|
      format.html { render 'show_add_probe', layout: request.xhr? ? false : true}
    end
  end


  def destroy
    @z_file = current_project.z_files.find(params[:id])
    @z_file.destroy

    respond_to do |format|
      format.html { redirect_to(project_chromosome_z_files_url) }
      format.xml  { head :ok }
    end
  end

  def destroy_all
    if params[:conditions] == 'true'
      ids = []
      list = current_project.z_files.all
      list.each do |zf|
        ids << zf.id
      end
    else
      ids = params[:conditions].match(/([\d,]+)\[\w+\]/)[1].split(',')
    end

    ids.each do |z_file_id|
      z_file = current_project.z_files.find(z_file_id)
      if current_user.can_delete?(z_file)
        z_file.destroy || fail('ZVI File(s) could not be deleted successfully.')
      end
    end
    head :ok
  end

  def delete_selected
    super current_project.z_files
  end

  # Stream a file that has already been generated and stored on disk
  def download_z_file
    z_file = Chromosome::ZFile.find(params[:id])
    send_file("#{Rails.root}/public/system/images/#{z_file.id}/original/#{z_file.file_name}", :disposition => 'attachment')
  end

  def download_z_files
    file_name = "ZVI_Files-#{Time.now}.zip"
    t = Tempfile.new("ZVI_Files-#{Time.now}")
    ids = params[:conditions].split
    Zip::ZipOutputStream.open(t.path) do |z|
      ids.each do |id|
        z_file = current_project.z_files.find(id)
        z.put_next_entry(z_file.file_name)
        z.print IO.read("#{Rails.root}/public/system/images/#{z_file.id}/original/#{z_file.file_name}")
      end
    end
    send_file t.path, :type => 'application/zip',
              :disposition => 'attachment',
              :filename => file_name
    t.close
    t.unlink
  end

end

