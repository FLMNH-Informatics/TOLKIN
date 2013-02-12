require 'restful/responder'

class PermissionSetsController < ApplicationController
  include Restful::Responder

  def index
    super(current_project.permission_sets)
  end
end