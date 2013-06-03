class CustomMappingsController < ApplicationController
  def destroy
    CustomMapping.find(params[:id]).destroy
    head :ok
  end
end