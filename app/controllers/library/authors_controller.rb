class Library::AuthorsController < ApplicationController
  include CitationsHelper
  include Restful::Responder

  before_filter :params_to_hash
  before_filter :requires_selected_project
  
  def index
    
    #render json: Library::Author.find_by_project_id(params[:project_id])
    params.include?(:limit)   || params[:limit] = 20
    params[:page] ? (params[:offset] =  (params[:limit].to_i * params[:page].to_i - 1)) : (!params.include?(:offset)? (params[:offset] = 0) : '')
    super current_project.authors
  end

  
end
