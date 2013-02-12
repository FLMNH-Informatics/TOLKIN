class Molecular::PrimersController < ApplicationController
  include Restful::Responder

  before_filter :requires_project_guest
  before_filter :requires_project_updater, :except => [ :index, :show ]
  before_filter :requires_selected_project

  def index
    query_params_provided? ||
      params.merge!(
        select: [ 
          :id, 
          :name, 
          :taxon_rtid, 
          :marker_id, 
          :purification_method_id 
        ],
        include: {
          taxon: { select: [ :rtid, :name ] },
          marker: { select: [ :id, :name ] },
          purification_method: { select: [ :id, :name ]}
        },
        limit: 20
    )
    super(Molecular::Primer.where(project_id: current_project.id))
  end

  def new
    super Molecular::Primer.where(project_id: current_project.id)
  end

  def show
    @primer = Molecular::Primer.for_project(current_project).find(params[:id])
    respond_to {|format| format.html { render 'show', layout: request.xhr? ? false : true } }
  end

  def create
    ActiveRecord::Base.transaction do
      @primer = Molecular::Primer.create!(params_for_save(*save_associations))
    end
    respond_to do |format|
      format.json { render json: { id: @primer.id } }
    end
  end

  def update
    primer = Molecular::Primer.find(params[:id])
    ActiveRecord::Base.transaction do
      primer.update_attributes!(params_for_save(*save_associations))
    end
    head :ok
  end

  def update_primer
    primer = Molecular::Primer.find(params[:id])
    ActiveRecord::Base.transaction do
      primer.update_attributes!(params_for_save(*save_associations))
    end
    head :ok
  end

  def destroy_all
    conditions = Restful::Parser.new.parse(params, :conditions)
    Molecular::Primer.where(project_id: current_project.id).where(conditions).destroy_all
    head :ok
  end

  def delete_selected
    super current_project.primers
  end

  private
  
  def save_associations
    ActiveRecord::Base.transaction do
      taxon =
        !params[:primer][:taxon_name].blank? && (
          passkey.unlock(Taxon).where(name: params[:primer][:taxon_name]).first || 
          passkey.unlock(Taxon).create!(name: params[:primer][:taxon_name]).reload # need to reload so that rtid is fetched and stored
        ) || nil


      marker =
        case params[:primer][:marker_id]
          when ""
            nil
          when "new"
            Molecular::Marker.for_project(current_project).where(name: params[:primer][:marker]).empty? ?
              Molecular::Marker.create!(name: params[:primer][:marker], project_id: current_project.project_id)
              : Molecular::Marker.for_project(current_project).where(name: params[:primer][:marker]).first
          else
            Molecular::Marker.find(params[:primer][:marker_id])
        end

      purification_method =
        case params[:primer][:purification_method_id]
          when ""
            nil
          when "new"
            Molecular::PurificationMethod.for_project(current_project).where(name: params[:primer][:purification_method]).empty? ?
              Molecular::PurificationMethod.create!(name: params[:primer][:purification_method], project_id: current_project.project_id)
              : Molecular::PurificationMethod.for_project(current_project).where(name: params[:primer][:purification_method]).first
          else
            Molecular::PurificationMethod.find(params[:primer][:purification_method_id])
        end

      [ taxon, marker, purification_method ]
    end
  end

  def params_for_save taxon, marker, purification_method
    params[:primer].reject{|k| [:taxon_name, :marker_name, :purification_method_name, :marker_id, :marker, :purification_method_id, :purification_method ].include?(k.to_sym)}.
      merge(taxon_rtid: taxon.try(:rtid), marker_id: marker.try(:id), purification_method_id: purification_method.try(:id))
  end

end
