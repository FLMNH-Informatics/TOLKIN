class Molecular::MarkersController < ApplicationController
  include Restful::Responder
  before_filter :requires_project_guest
  before_filter :requires_project_updater
  before_filter :requires_selected_project
  
  auto_complete_for 'Molecular::Marker', :name, :project_scope => true

  def resource
    Molecular::Marker
  end

  def index
    @markers = Molecular::Marker.includes(:timelines, :seqs).where(:project_id => current_project.project_id).order(:name)
  end

  def update
    @marker = Molecular::Marker.find(params[:id])
    if @marker.update_attributes({:name => params[:name], :type => params[:type]})
      respond_to {|format| format.json { render :json => {:row => render_to_string(:partial => "marker_row.html.erb", :locals => {:marker => @marker}) } } }
    end
  end

  def display_seqs
    @marker = Molecular::Marker.find(params[:id])
    @sequences = @marker.seqs
    respond_to{|format|format.html{render 'display_seqs', layout: request.xhr? ? false : 'application'}}
  end

  def display_primers
    @marker = Molecular::Marker.find(params[:id])
    @primers = @marker.primers
    respond_to{|format|format.html{render 'display_primers', layout: request.xhr? ? false : 'application'}}
  end

  def display_matrices
    @marker = Molecular::Marker.find(params[:id])
    timelines = @marker.timelines
    grouped_by_matrix = timelines.group_by{|timeline| timeline.matrix}
    grouped_and_sorted = []
    grouped_by_matrix.values.each do |group|
      grouped_and_sorted.push(group.sort_by{|a,b|(a.nil? ? 0 : a.version_number)<=>(b.nil? ? 0 : b.version_number)})
    end
    @timelines = grouped_and_sorted.flatten
    respond_to{|format|format.html{render 'display_matrices', layout: request.xhr? ? false: 'application'}}
  end

  def merge
    first_marker  = Molecular::Marker.find(params[:id1])
    second_marker = Molecular::Marker.find(params[:id2])
    if first_marker.name.downcase == second_marker.name.downcase
      @marker = first_marker.merge(second_marker)
      respond_to {|format| format.json { render :json => {:row => render_to_string(:partial => "marker_row.html.erb", :locals => {:marker => @marker}) } } }
    else
      respond_to {|format| format.json { render :json => {:msg => "Markers didn't have the same name.'"}}}
    end
  end

  def destroy
    @marker = Molecular::Marker.find(params[:id])
    if @marker
      @marker.destroy!
      respond_to{|format|format.json{ render :json => {:success => true}}}
    elsif @marker.nil?
      respond_to{|format|format.json{ render :json => {:error => "Marker didn't exist"}}}
    else
      respond_to{|format|format.json{ render :json => {:error => "Problem deleting marker"}}}
    end
  end

  def delete_selected
    marker_ids = params[:ids].split(',')
    @markers = Molecular::Marker.find(marker_ids)
    Molecular::Marker.transaction{ @markers.each{|marker| marker.destroy! unless marker.nil? }}
    respond_to{|format| format.json{ render :json => {:success => true}}}
  end

end
