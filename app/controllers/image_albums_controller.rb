class ImageAlbumsController < ApplicationController

  include Restful::Responder

  before_filter :requires_project_guest, :except => [ ]
  before_filter :requires_project_updater, :except => [ ]

  def index
    where_hash = {}
    params[:search].each_pair do |type,term|
      unless term.blank?
        term = %(%#{term}%)
        case type
          when 'taxon'        then where_hash[:taxa] = {:name.matches => term}
          when 'caption'      then where_hash[:caption.matches] = term
          when 'photographer' then where_hash[:photographers_credits.matches] = term
          when 'distribution' then where_hash[:taxa] = {:general_distribution.matches => term }
          when 'subgenus'     then where_hash[:taxa] = {:sub_genus.matches => term }
          when 'section'      then where_hash[:taxa] = {:section.matches => term }
          when 'subsection'   then where_hash[:taxa] = {:subsection.matches => term }
        end
      end
    end unless params[:search].nil? || params[:search].blank?
    where_hash[:thumbnail] = nil
    where_hash[:project_id] = current_project.project_id.to_s
    @images = current_project.images.joins(:taxon_images.outer => :taxon.outer).where(where_hash).order(:id).paginate(:page => params[:page], :per_page => 55 )
    if request.xhr?
      render(:partial => 'image_albums/image_album_and_paginate', layout: false)
    else
      render 'index'
    end
  end

  def show

  end

  def get_image
    @image = current_project.images.find(params[:imageId])

    respond_to do |format|
      format.html { render :layout => false  }
      format.xml  { render :xml    => @image }
      format.json { render :json   => @image }
    end
  end

  def update_image
    @image = current_project.images.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { render :layout => false  }
        format.xml  { render :xml    => @image }
        format.json { render :json   => @image, :head => :ok}
      else
        format.html { render :layout => false, :action => "get_image"}
        format.xml  { render :xml    => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

end