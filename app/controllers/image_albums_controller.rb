class ImageAlbumsController < ApplicationController

  include Restful::Responder

  before_filter :requires_project_guest, :except => [ ]
  before_filter :requires_project_updater, :except => [ ]

  def index

    if params[:search_terms].nil? || params[:search_terms].empty?
      @images = current_project.images.where("thumbnail IS NULL").order(:id).paginate(:page => params[:page], :per_page => 55 )
    else
      @search_images = []
      queries_combined = []

      params[:search_parameters].each_with_index do |search_parameter, search_parameter_index|
        term = params[:search_terms][search_parameter_index]

        case search_parameter
          when 'taxon'

            query = []
            #Test Taxon in Euphorbia: Adenopetalum mexicanum
            @project_images = current_project.images.order(:id)
            tax = passkey.unlock(Taxon)
            @project_images.each do |image|
              begin
                if tax.find(image.image_joins.first[:object_id]).name.downcase.include? term.downcase
                  query << image
                end
              rescue
              end
            end

          when 'caption'
            query = current_project.images.where("project_id = '#{params[:project_id]}' AND caption iLIKE '%#{term}%'")
          when 'photographer'
            query = current_project.images.where("project_id = '#{params[:project_id]}' AND photographer iLIKE '%#{term}%'")
          when 'location'
            query = []
            #Test Taxon in Euphorbia: Adenopetalum mexicanum
            @project_images = current_project.images.order(:id)
            tax = passkey.unlock(Taxon)

            search_taxon = tax.where("general_distribution iLIKE '%#{term}%'")

            search_taxon.each do |taxon|
              if !taxon.images.empty?
                query << taxon.images
              end
            end

            query.flatten!
        end

        if queries_combined.empty?
          queries_combined << query
        else
          queries_combined | query
        end
      end
      queries_combined.flatten!

      @images = queries_combined.paginate(:page => params[:page], :per_page => 55)
    end

    if params[:search_terms]
      respond_to do |format|
        format.html {render :partial => 'image_albums/image_album', layout: false}
      end
    else
      render 'index'
    end

  end

  def search

    if params[:search].nil? || params[:search].empty?
      @images = current_project.images.where("thumbnail IS NULL").order(:id).paginate(:page => params[:page], :per_page => 55 )
    else
      
      @search_images = []
      queries_combined = []

      params[:search].first.each_with_index do |search_parameter, search_parameter_index|
        #term = params[:search][search_parameter_index]
        term = search_parameter[1].first

        case search_parameter.first
          when 'taxon'
            taxon_sql = %(
              SELECT
                images.*
              FROM
                images, images_joins, taxa
              WHERE
                images_joins.image_id = images.id AND
                taxa.taxon_id = images_joins.object_id  AND
                images_joins.object_type = 'Taxon' AND
                images.thumbnail is NULL AND
                images.project_id = #{current_project.project_id.to_s} AND
                taxa.name ilike '%#{term.downcase}%'
            )
            query = Image.find_by_sql(taxon_sql)
          when 'caption'
            query = current_project.images.where("project_id = '#{params[:project_id]}' AND caption iLIKE '%#{term}%'")
          when 'photographer'
            query = current_project.images.where("project_id = '#{params[:project_id]}' AND photographers_credits iLIKE '%#{term}%'")
          when 'location'
            query = []
            search_taxon = passkey.unlock(Taxon).where("general_distribution iLIKE '%#{term}%'")
            search_taxon.each do |taxon|
              if !taxon.images.empty?
                query << taxon.images
              end
            end
            query.flatten!
        end

        if queries_combined.empty?
          queries_combined << query
        else
          queries_combined | query
        end
      end
      queries_combined.flatten!

      @images = queries_combined.paginate(:page => params[:page], :per_page => 55)
    end
      respond_to do |format|
        format.html {render :partial => 'image_albums/image_album_and_paginate', layout: request.xhr? ? false : true}
      #  format.html {render :partial => 'image_albums/image_album', layout: true}
      end

  end

  def show
    #@image = Image.thumbs.find :all,
    #                           :include => {:parent => {:image_taxon => :taxon, :image_collection => :collection}},
    #                           :conditions => {'images.project_id' => @current_project}
    #respond_to do |format|
    #  format.html { render :layout => false} # show.html.erb
    #  format.xml  { render :xml => @image }
    #  format.json {render :json => @image}
    #end
  end

  def get_image
    @image = current_project.images.find(params[:imageId])

    respond_to do |format|
      format.html { render :layout => false} # show.html.erb
      format.xml  { render :xml => @image }
      format.json {render :json => @image}
    end
  end

  def update_image
    @image = current_project.images.find(params[:id])

    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { render :layout => false} # show.html.erb
        format.xml  { render :xml => @image }
        format.json {render :json => @image, :head => :ok}
      else
        format.html { render :layout => false, :action => "get_image"}
        format.xml { render :xml => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

end