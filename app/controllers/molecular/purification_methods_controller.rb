class Molecular::PurificationMethodsController < ApplicationController
  include Restful::Responder

  def resource
    Molecular::PurificationMethod
  end

  def index
    super Molecular::PurificationMethod.where(project_id: current_project.id)
  end
end