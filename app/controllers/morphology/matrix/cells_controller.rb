class Morphology::Matrix::CellsController < ApplicationController
  include Restful::Responder
  include Morphology::MatricesHelper
  include MatricesHelper

  def show
    @project = current_project
    @timeline = Morphology::Matrix::Timeline.find(params[:matrix_id])
    @cell = Morphology::Matrix::Cell.find(params[:id])
    @images = @cell.images
    @character = @cell.character
    @otu = @cell.otu
    super @timeline.cells
  end

  def show_cell_info
    @project = current_project
    @timeline = Morphology::Matrix::Timeline.find(params[:matrix_id])
    @cell = Morphology::Matrix::Cell.find(params[:id])
    @images = @cell.images
    @character = @cell.character
    @otu = @cell.otu
    respond_to { |format| format.html { render 'show_cell_info', layout: request.xhr? ? false : true } }
  end

  def update
    params["cell"]["state_codings"] = params["cell"]["state_codings"].join(" ") if params["cell"]["state_codings"].is_a?(Array)
    file = {}
    file[:attachment] = params[:cell].delete("uploaded_data")
    Morphology::Matrix::Cell.transaction do
      @timeline = Morphology::Matrix::Timeline.find(params[:matrix_id])
      old_cell = Morphology::Matrix::Cell.find(params[:id])
      previous = Morphology::Matrix::Cell.where('character_id = ? and otu_id = ? and timeline_id = ? and is_active = true', old_cell.character_id, old_cell.otu_id, @timeline.id).order('create_date')
      if previous.empty?
        @cell = old_cell.overwrite(params[:cell])
      else
        previous.each do |cell|
          if cell == previous.last
            @cell = cell.overwrite(params[:cell])
          else
            if cell.is_active != false || cell.overwrite_date.nil?
              cell.is_active = false
              cell.overwrite_date = DateTime.now.utc
              cell.save!
            end
          end
        end
      end
      unless file[:attachement].nil?
        @image = Image.create!(file.merge({:created_by => current_user.user_id}))
        @cell.images << @image
      end
      #@character = Morphology::Character.find(params[:cell][:character_id])
      @character =  @cell.character
      #@otu = Otu.find(params[:cell][:otu_id])
      @otu = @cell.otu
    end
    respond_to do |format|
      format.json { render :json => { :msg => "Cell updated.", :cell_id => @cell.id, :cell => matrix_cell(@cell.character, @cell.otu, @cell)} }
      format.html { render :text => { :msg => "Cell updated.",
                                     :td_id => "c_" + @otu.id.to_s + "_" + @character.id.to_s,
                                     :cell => matrix_cell_hash(@cell.character,@cell.otu,@cell) }.to_json }
    end
  end

  def new
    @project = current_project
    @timeline = Morphology::Matrix::Timeline.find(params[:matrix_id])
    @character = Morphology::Character.find(params[:charId])
    @otu = Otu.find(params[:otuId])
    super @timeline.cells
  end

  def create
    Morphology::Matrix::Cell.transaction do
      file = {}
      file[:attachment] = params[:cell].delete("uploaded_data")
      params[:cell][:state_codings] = params[:cell][:state_codings].join(" ") if params[:cell][:state_codings].is_a?(Array)
      @timeline = Morphology::Matrix::Timeline.find(params[:matrix_id])
      previous = Morphology::Matrix::Cell.where('character_id = ? and otu_id = ? and timeline_id = ? and is_active = true', params[:cell]["character_id"], params[:cell]["otu_id"], @timeline.id).order('create_date')
      if previous.empty?
        @cell = @timeline.cells.create!(params[:cell])
      else
        previous.each do |cell|
          if cell == previous.last
            @cell = cell.overwrite(params[:cell])
          else
            cell.is_active = false
            cell.overwrite_date = DateTime.now.utc
            cell.save!
          end
        end
      end
      ##upload
      unless file[:attachment].nil?
        @image = Image.create!(file.merge({:created_by => current_user.user_id}))
        @cell.images << @image
      end
      @character = Morphology::Character.find(params[:cell][:character_id])
      @otu = Otu.find(params[:cell][:otu_id])
    end
    respond_to do |format|
      format.json {render :json => { :msg => "Cell updated.", :cell_id => @cell.id } }
      format.html {render :text => { :msg => "Cell updated.",
                                     :td_id => "c_" + @otu.id.to_s + "_" + @character.id.to_s,
                                     :cell => matrix_cell_hash(@character,@otu,@cell) }.to_json }
    end
  end

  def remove_citation
    @cell = Morphology::Matrix::Cell.find(params[:id]).overwrite
    @cell.citations = (@cell.citations - [Library::Citation.find(params['citation_id'])])
    @cell.save
    respond_to {|format| format.json { render :json => {'cell_id' => @cell.id,
                                                        'citation_id' => params['citation_id'],
                                                        :td_id => "c_" + @cell.otu.id.to_s + "_" + @cell.character.id.to_s,
                                                        :cell => matrix_cell_hash(@cell.character,@cell.otu,@cell) }}}
  end

  def remove_image
    @cell = Morphology::Matrix::Cell.find(params[:id]).overwrite
    @cell.images = (@cell.images - [Image.find(params['image_id'])])
    @cell.save
    respond_to {|format| format.json { render :json => {'cell_id' => @cell.id,
                                                        'image_id' => params['image_id'],
                                                        :td_id => "c_" + @cell.otu.id.to_s + "_" + @cell.character.id.to_s,
                                                        :cell => matrix_cell_hash(@cell.character,@cell.otu,@cell) }}}
  end

  def show_add_citation
    @cell = Morphology::Matrix::Cell.find(params[:id])
    respond_to{|format|format.html{ render 'show_add_citation', layout: request.xhr? ? false : true }}
  end

  def citation_add
    #debugger
    begin
      @cell = Morphology::Matrix::Cell.find(params[:id]).overwrite
      @cell.add_citations(params[:citation_ids]) if params.has_key?(:citation_ids)
      params['id'], params[:id] = @cell.id, @cell.id
      #debugger
      #head :ok
      @images = @cell.images
      @character = @cell.character
      @otu = @cell.otu
      @timeline = @cell.timeline
      respond_to{|format|format.json { render :json => {:cell_id => @cell.id} }}
    rescue => e
      debugger
      head :internal_server_error
    end
  end
end

