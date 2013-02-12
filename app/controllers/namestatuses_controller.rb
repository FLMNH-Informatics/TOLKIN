class NamestatusesController < ApplicationController

  def index
    status = Namestatus.all

    respond_to do |format|
      format.html  # index.html.erb
      format.json {  render :json => { :status => status }, :content_type => 'application/json' }
      #format.json  { render :json => @status }
    end
  end
end