module Publifier
  include Restful::Responder
  def self.included(base)
    base.before_filter :set_model, :only => [:make_public,:make_all_public,:make_private,:make_all_private,:get_public_status]
  end

  #IMPORTANT sets the correct model name for matrices (using MatrixView for catalog)
  #if you want matrices to be public besure to include type::MatrixView in intializers/active_record_publifier.rb self.public_models
  def set_model
    model_path = params[:path].camelize.singularize
    @model_for_publifier = model_path.end_with?("Matrix") ? model_path.gsub("Matrix","MatrixView").constantize : model_path.constantize
  end

  def make_public
    validate(params) && parse(params)
    #@model_for_publifier.try(:for_project, current_project).find(params[:ids]).each{|item|item.make_public}
    items = @model_for_publifier.try(:for_project, current_project).scoped.apply_finder_options(prepare(params, for: :finder))
    items.each{|item|item.make_public}
    respond_to do |format|
      format.json { render :json => { :msg => "ok" } }
    end
  end

  def make_all_public
    @model_for_publifier.try(:for_project, current_project).each{|item|item.make_public}
    respond_to{|format|format.json{render :json => {:msg => 'ok'}}}
  end

  def make_private
    validate(params) && parse(params)
    items = @model_for_publifier.try(:for_project, current_project).scoped.apply_finder_options(prepare(params, for: :finder))
    items.each{|item|item.make_private}
    #@model_for_publifier.try(:for_project, current_project).find(params[:ids]).each{|item|item.make_private}
    respond_to{|format|format.json{render :json => {:msg => 'ok'}}}
  end

  def make_all_private
    @model_for_publifier.try(:for_project, current_project).each{|item|item.make_private}
    respond_to{|format|format.json{render :json => {:msg => 'ok'}}}
  end

  def get_public_status
    status = false
    if params[:record_id] && params[:record_id] != "undefined" && model.public_model?
      record = @model_for_publifier.find(params[:record_id])
      if (record.public_model?)
        status = @model_for_publifier.find(params[:record_id]).public_record?
      end
    end
    respond_to{|format|format.json{render :json => {:public_status => status}}}
  end

  def get_public_model_status
    status = @model_for_publifier.public_model?
    respond_to{|format|format.json{render :json => {:public_status => status}}}
  end

end
