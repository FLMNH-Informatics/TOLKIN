require 'zip/zip'

class Chromosome::ProbesController < ApplicationController
  include Restful::Responder
  include BulkUploader

  before_filter :params_to_hash

  before_filter :requires_project_guest, :except => [:index, :show ]
  before_filter :requires_project_updater, :except => [:index, :show ]
  # before_filter :requires_project_manager, :except => [ ]
  #skip_before_filter :requires_any_guest, :only => [ :index, :show ]
  # GET /probes
  # GET /probes.xml

  def show_new_upload
      super resource
    end

    def new_upload
      super resource
    end

    def bulk_upload
      super resource
    end

    def view_map
      super
    end

    def resource
      Chromosome::Probe
    end

  def index
    query_params_provided? ||
        params.merge!(
            order: 'probes.value',
            select: [ 'id', 'value', 'probe_type', 'scaffold_id', 'chromosome', 'genome_builder_super_scaffold'],
            limit: 20
        )
    super(current_project.probes)
  end
  
  def z_files
    probe = current_project.probes.find(params[:id])
    z_files = probe.z_files
    unless z_files.empty?
      file_name = "ZVI_Files-#{Time.now}.zip"
      t = Tempfile.new("ZVI_Files-#{Time.now}")
      Zip::ZipOutputStream.open(t.path) do |z|
        z_files.each do |file|
          z.put_next_entry(file.zvi_file_name)
          z.print IO.read("#{Rails.root}/public#{file.zvi.url(:original, false)}")
        end
      end
      send_file t.path, :type => 'application/zip',
              :disposition => 'attachment',
              :filename => file_name
      t.close
      t.unlink
    else
      respond_to{|format| format.json {render :json => "There are no ZVI files associated with this probe."}}
    end
  end

  def show
    @probe = current_project.probes.find(params[:id])
    @z_files = @probe.z_files
    @hybrids = @probe.hybridizations
    super Chromosome::Probe
    #respond_to do |format|
    #    format.html { render 'show', layout: request.xhr? ? false : true }
    #    format.xml  { render :xml => @probe }
    #end
  end

  def new
    @probe = current_project.probes.new

    respond_to do |format|
      format.html {render :layout => false}
      format.xml  { render :xml => @probe }
    end
  end

  def edit
    @probes = current_project.probes.find(params[:id])
  end

  def create
    @probe = current_project.probes.create(params[:chromosome_probe])
    respond_to do |format|
      format.html { redirect_to project_chromosome_probes_path, :notice => 'Probe was successfully created.' }
      format.json { render :json => @probe, :status => :created }
    end
  end

  def update
    @probes = current_project.probes.find(params[:id])

    respond_to do |format|
      if @probes.update_attributes(params[:probe])
        format.html { redirect_to project_chromosome_probes_path, :notice => 'Probe was successfully updated.' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @probes.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /probes/1
  # DELETE /probes/1.xml
  #def destroy
  #
  #  @probe = current_project.probes.find(params[:id])
  #  @probe.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to(project_chromosome_probes_url) }
  #    format.xml  { head :ok }
  #  end
  #end

  def delete_selected
    super current_project.probes
  end

  def destroy_all
    if params[:conditions] == 'true'
      ids = []
      list = current_project.probes.all
      list.each do |zf|
        ids << zf.id
      end
    else
      unless ids = params[:conditions].match(/([\d,]+)\[\w+\]/)[1].split(',')
        ids = [params[:conditions]]
      end
    end

    ids.each do |id|
      probe = current_project.probes.find(id)
      if current_user.can_delete?(probe)
        probe.destroy || fail('Probe(s) could not be deleted successfully.')
      end
    end
    head :ok
  end

  def tooltip_show
    @probe = current_project.probes.find(params[:probeId])
    @sequence_contigs = @probe.sequence_contigs
    @dyes = @probe.dyes
    @z_files = @probe.z_files

    respond_to do |format|
      format.html { render 'tooltip_show.html.erb', layout: request.xhr? ? false : true }# show.html.erb
      format.xml  { render :xml => @probe }
    end
  end

end
