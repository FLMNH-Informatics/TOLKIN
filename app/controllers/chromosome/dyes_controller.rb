
class Chromosome::DyesController < ApplicationController
  include Restful::Responder

  before_filter :requires_project_guest, :except => [ ]
  before_filter :requires_project_updater, :except => [ ]
  # before_filter :requires_project_manager, :except => [ ]


  def index
    @dyes = current_project.dyes.order(:id).all

    query_params_provided? ||
      params.merge!(
      order: 'dye_value',
      select: [ 'id', 'dye_value'],
      limit: 20
    )
    super(current_project.dyes)
  end


  def new
    
    @dyes = current_project.dyes.order(:id)
    @probes = current_project.probes.find(params[:probe_id])
    query_params_provided? ||
      params.merge!(
      order: 'dye_value',
      select: [ 'id', 'dye_value'],
      limit: 20
    )

    super(current_project.dyes)
  end

  def create
    dye = Chromosome::Dye.create!({:dye_value => params[:dye_value]})
    respond_to do |format|
      format.json { render :json => { :dye => {:dye_value => dye.dye_value, :id => dye.id.to_s } }}
    end
  end

  def show
    @probe = current_project.probes.find(params[:probe_id])
    @dye = current_project.dyes.find(params[:id])

    respond_to do |format|
      format.html { render :html => @dye }# show.html.erb
      format.xml  { render :xml => @dye }
    end
  end

  def edit
    id = params[:conditions].match(/([\d,]+)\[\w+\]/)[1].split(',').first

    @dye = current_project.dyes.find(id)
    @probe = current_project.probes.find(params[:id])

  end

  def update
   
    @dye = current_project.dyes.find(params[:id])

    respond_to do |format|
      if @dye.update_attributes(params[:dye])

        format.html { redirect_to(project_chromosome_probe_path(current_project, params[:probe_id]), :notice => 'Dye was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dye.errors, :status => :unprocessable_entity }
      end
    end
  end


  def destroy
    @dye = current_project.dyes.find(params[:id])
    @dye.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end

  def destroy_all
    ids = params[:conditions].match(/([\d,]+)\[\w+\]/)[1].split(',')
    ids.each do |id|
      dye = current_project.dyes.find(id)
      if current_user.can_delete?(dye)
        dye.destroy || fail('Dye(s) could not be deleted successfully.')
      end
    end
    head :ok
  end

end