require 'rubygems'
require 'spreadsheet'
require 'csv'
require 'roo'
require 'base64'

class Collections::BulkUploadsController < ApplicationController
  #TODO Remove this function once use
=begin
  def import_kina
    project = Project.where("label = ?", 'Kinaballua Dicots').first
    ProjectStamper.instance.project =  project
    user = User.where("username = ?", 'rbeaman').first
    UserSignature.instance.user = user

    #name author parser by species name identifier
    matcher = '/(\A[A-Z][a-z\s\d.-]+)([\(A-Z][\d\w\W]+)*/',  #matches taxon name from author
    paths = ["/db/migrate/kina_data/kina_names_an.csv","/db/migrate/kina_data/kina_names_oz.csv" ]#fix this
    taxas = {}

    paths.each do |path|
      CSV.foreach("#{Rails.root}#{path}", :headers => :first_row, :row_sep => :auto, :header_converters => :symbol) do |row|
        matches = row[:name].match(/(\A[A-Z][a-z\s\d.-]+)([\(A-Z][\d\w\W]+)*/)
        if matches.respond_to?(:length) && matches.length > 0
          taxon = Taxon.new
          taxon.name = matches[1].strip
          taxon.author = matches[2].strip if !matches[2].blank?
          taxon.habitat = row[:habitat]
          taxon.infra_name = row[:infraname]
          taxon.description = row[:lifeform]
          taxon.notes = row[:remarks].to_s +  ' ' +  row[:citation].to_s

          taxon.save!
          taxas[matches[1].to_s.downcase.strip]=taxon.taxon_id
        end    
      end
    end

    paths = ["/db/migrate/kina_data/dicot_al.csv","/db/migrate/kina_data/dicot_mz.csv" ]
    paths.each do |path|
      CSV.foreach("#{Rails.root}#{path}", :headers => :first_row, :row_sep => :auto, :header_converters => :symbol) do |row|
        matches = row[:name].match(/(\A[A-Z][a-z\s\d.-]+)([\(A-Z][\d\w\W]+)*/)
        if matches.respond_to?(:length) && matches.length > 0
          begin
            col = Collection.new
            if taxas.has_key?(matches[1].to_s.downcase.strip)
              col.taxon_id = taxas[matches[1].to_s.downcase.strip]
            else
              taxon = Taxon.new
              taxon.name = matches[1].strip
              taxon.author = matches[2].strip if !matches[2].blank?
              taxon.infra_name = row[:infraname]
      
              taxon.save!
              taxas[matches[1].to_s.downcase.strip]=taxon.taxon_id
              col.taxon_id = taxon.taxon_id
            end
            col.project = project
            col.recpermission_id = 2
            col.user = user
            col.collector = row[:collector]
            col.collection_number = row[:number]
            col.elevation_start = row[:elevationf] 
            col.elevation_end = row[:elevatinfl] 
            col.verbatim_coll_date = row[:date]
            col.locality = row[:locality]
            col.prefix = row[:prefix]
            col.suffix = row[:suffix]
            col.notes = row[:notes] 
            col.notes <<  '   detdate: '+ row[:detdate] if row.respond_to?(:detdate)
            col.notes <<  '   pltdescr: ' + row[:pltdescr] if row.respond_to?(:pltdescr)
            col.notes <<  '   herbarium:  ' + row[:herbarium] if row.respond_to?(:herbarium)
            col.type_status = row[:typestatus]
            col.plant_description = row[:pltdescr]
            col.vegetation = row[:vegitation]
            col.geology = row[:geology]
            col.save!
          rescue 
            next
          end
        end    
      end
    end

    render :text => 'Import Done!'
  end
  #REMOVE above method
=end

  def new_bulk_upload(params, file_name)
    @csv_file_path = "#{Rails.root}/private/files/#{params[:upload_type]}/bulk_uploads_temp_files/#{file_name}.csv"
    @custom_file_columns = []
    CSV.foreach(@csv_file_path, :headers => :first_row, :row_sep => :auto) do |row|

      @custom_file_columns = row.headers
    end
    if params[:upload_type] == 'collections'

      collection_columns_to_change = {
          'id' => nil, "coll_start_date" => nil, "coll_end_date" => nil, "taxon_id" => nil,
          "last_updated_by" => nil, "user_id" => nil, "project_id" => nil,
          "created_at" => nil, "updated_at" => nil, "long_min_old" => nil, "long_sec_old" => nil,
          "long_degree_old" => nil, "lat_min_old" => nil, "lat_sec_old" => nil,
          "lat_degree_old" => nil, "higher_geography" => nil, "continent" => nil, "image_url" => nil,
          "guid" => nil, "old_tolkin_id" => nil, "copied_from_id" => nil, "lat_degree_old" => nil,
          "higher_geography" => nil, "continent" => nil, "image_url" => nil, "elevation_unit_id" => nil,
          "accuracy_other" => nil, "annotations_old" => nil, "calc_lat_dd" => nil, "calc_lat_dd_old" => nil,
          "calc_long_dd" => nil, "calc_long_dd_old" => nil, "collecting_method" => nil, "date_trans" => nil,
          "recpermission_id" => nil, "max_depth_in_meters" => nil, "min_depth_in_meters" => nil,
          "valid_distribution_flag" => nil, "length_unit_id" => nil, "longitude" => nil,
          "latitude" => nil, "label_text" => nil,
          'accession_num' => 'ACCESSION #', "coll_end_date_dd" => "COL END DAY",
          "coll_end_date_mm" => "COL END MONTH", "coll_end_date_yyyy" => "COLD END YEAR",
          "coll_start_date_dd" => "COL START DAY", "coll_start_date_mm" => "COL START MONTH",
          "coll_start_date_yyyy" => "COL START YEAR", "collection_number" => "COLLECTION #",
          "lat_dd" => "LATITUDE DECIMAL DEGREES", "lat_deg" => "LATITUDE DEGREES",
          "lat_dir" => "LATITUDE DIRECTION", "lat_long_rep" => "LOCALITY FORMAT",
          "lat_min" => "LATITUDE MINUTES", "lat_sec" => "LATITUDE SECONDS",
          "long_dd" => "LONGITUDE DECIMAL DEGREES", "long_deg" => "LONGITUDE DEGREES",
          "long_dir" => "LONGITUDE DIRECTION", "long_min" => "LONGITUDE MINUTES",
          "long_sec" => "LONGITUDE SECONDS", "verbatim_coll_date" => "VERBATIM COL DATE"}

      @collection_attributes = Collection.column_names

      @option_attributes = Hash.new

      collection_columns_to_change.each do |key|
        @option_attributes[key[0]]= key[1] unless collection_columns_to_change[key[0]] == nil
      end

      @collection_attributes.each do |column|
        if collection_columns_to_change.has_key?(column) == false && column.include?("_")
          label = column.upcase.gsub!('_', ' ') #unless collection_columns_to_change[column] == nil
        elsif collection_columns_to_change.has_key?(column) == true && column.include?("_")
          label = collection_columns_to_change[column]
        elsif collection_columns_to_change.has_key?(column) == false
          label = column.upcase
        end

        if label
          @option_attributes[column] = label unless @option_attributes.has_key?(column)
        else
          @option_attributes.delete(column)
        end
      end

      ordered_hash = Hash.new
      @option_attributes.sort.each do |deep_hash|
        ordered_hash[deep_hash[0]] = deep_hash[1]

      end

      @option_attributes = ordered_hash

    elsif params[:upload_type] == 'taxa'

      taxon = passkey.unlock(Taxon)

      taxon_columns_to_change = {
          "taxon_id" => nil, "rtid" => nil, "vtid" => nil, "owner_user_id" => nil, "owner_record_rtid" => nil,
          "owner_graph_rtid" => nil, "owner_permission_set_rtid" => nil, "creator_rtid" => nil, "created_at" => nil, "updater_rtid" => nil,
          "updated_at" => nil, "old_tolkin_id" => nil, "old_accepted_name" => nil, "has_children" => nil, "deleted_at" => nil, "ubio_id" => nil,
          "ncbi_id" => nil, "treebase_id" => nil, "copied_from_id" => nil, "type_date" => nil,
          "author" => "AUTHOR", "basionym" => "BASIONYM", "chromosome_number" => "CHROMOSOME NUMBER", "comments" => "COMMENTS",
          "commonname" => "COMMON NAME", "conservation_status" => "CONSERVATION STATUS", "custom_tag" => "CUSTOM TAG",
          "description" => "DESCRIPTION", "editors" => "EDITORS", "general_distribution" => "GENERAL DISTRIBUTION",
          "habitat" => "HABITAT", "infra_author" => "INFRA AUTHOR", "infra_name" => "INFRA NAME", "ingroup_clade" => "INGROUP CLADE",
          "major_group" => "MAJOR GROUP", "name" => "NAME", "neotype" => "NEOTYPE", "notes" => "NOTES", "pages" => "PAGES",
          "phylogenic_relationship" => "PHYLOGENIC RELATIONSHIP", "publication" => "PUBLICATION", "publication_date" => "PUBLICATION DATE",
          "section" => "SECTION", "sub_genus" => "SUB GENUS", "subclade" => "SUBCLADE", "subsection" => "SUBSECTION",
          "temp_family" => "TEMPORARY FAMILY", "temp_genus" => "TEMPORARY GENUS", "temp_species" => "TEMPORARY SPECIES",
          "toxicity" => "TOXICITY", "type_collection" => "TYPE COLLECTION", "type_herbaria" => "TYPE HERBARIA",
          "type_locality" => "TYPE LOCALITY", "type_species" => "TYPE SPECIES", "uses" => "USES", "volume_num" => "VOLUME NUMBER", "year" => "YEAR"
      }

      @taxon_attributes = taxon.column_names

      @taxon_option_attributes = Hash.new

      taxon_columns_to_change.each do |key|
        @taxon_option_attributes[key[0]]= key[1] unless collection_columns_to_change[key[0]] == nil
      end

      @taxon_attributes.each do |column|
        if taxon_columns_to_change.has_key?(column) == false && column.include?("_")
          label = column.upcase.gsub!('_', ' ') #unless collection_columns_to_change[column] == nil
        elsif taxon_columns_to_change.has_key?(column) == true && column.include?("_")
          label = taxon_columns_to_change[column]
        elsif taxon_columns_to_change.has_key?(column) == false
          label = column.upcase
        end

        if label
          @taxon_option_attributes[column] = label unless @taxon_option_attributes.has_key?(column)
        else
          @taxon_option_attributes.delete(column)
        end
      end

      ordered_hash = Hash.new
      @taxon_option_attributes.sort.each do |deep_hash|
        ordered_hash[deep_hash[0]] = deep_hash[1]
      end
      @option_attributes = ordered_hash
    elsif params[:upload_type] == 'citations'

    end
    @created_custom_mappings = current_project.custom_mappings.where('user_id = ?', current_user.user_id)

    respond_to do |format|
      format.html { render :partial => 'new_bulk_upload', :layout => false }
    end
  end

  def column_module_type
    if params[:ar]
      taxon = passkey.unlock(Taxon)

      taxon_columns_to_change = {
          "taxon_id" => nil, "rtid" => nil, "vtid" => nil, "owner_user_id" => nil, "owner_record_rtid" => nil,
          "owner_graph_rtid" => nil, "owner_permission_set_rtid" => nil, "creator_rtid" => nil, "created_at" => nil, "updater_rtid" => nil,
          "updated_at" => nil, "old_tolkin_id" => nil, "old_accepted_name" => nil, "has_children" => nil, "deleted_at" => nil, "ubio_id" => nil,
          "ncbi_id" => nil, "treebase_id" => nil, "copied_from_id" => nil, "type_date" => nil,
          "temp_family" => "TEMPORARY FAMILY", "temp_genus" => "TEMPORARY GENUS", "temp_species" => "TEMPORARY SPECIES",
          "volume_num" => "VOLUME NUMBER"}

      @taxon_attributes = taxon.column_names

      @taxon_option_attributes = Hash.new

      taxon_columns_to_change.each do |key|
        @taxon_option_attributes[key[0]]= key[1] unless taxon_columns_to_change[key[0]] == nil
      end

      @taxon_attributes.each do |column|
        if taxon_columns_to_change.has_key?(column) == false && column.include?("_")
          label = column.upcase.gsub!('_', ' ') #unless collection_columns_to_change[column] == nil
        elsif taxon_columns_to_change.has_key?(column) == true && column.include?("_")
          label = taxon_columns_to_change[column]
        elsif taxon_columns_to_change.has_key?(column) == false
          label = column.upcase
        end
        if label
          @taxon_option_attributes[column] = label unless @taxon_option_attributes.has_key?(column)
        else
          @taxon_option_attributes.delete(column)
        end
      end
      ordered_hash = Hash.new
      @taxon_option_attributes.sort.each do |deep_hash|
        ordered_hash[deep_hash[0]] = deep_hash[1]
      end

      @taxon_option_attributes = ordered_hash
      collection_columns_to_change = { 'id' => nil, "coll_start_date" => nil, "coll_end_date" => nil, "taxon_id" => nil,
                                       "last_updated_by" => nil, "user_id" => nil, "project_id" => nil,
                                       "created_at" => nil, "updated_at" => nil, "long_min_old" => nil, "long_sec_old" => nil,
                                       "long_degree_old" => nil, "lat_min_old" => nil, "lat_sec_old" => nil,
                                       "lat_degree_old" => nil, "higher_geography" => nil, "continent" => nil, "image_url" => nil,
                                       "guid" => nil, "old_tolkin_id" => nil, "copied_from_id" => nil, "lat_degree_old" => nil,
                                       "higher_geography" => nil, "continent" => nil, "image_url" => nil, "elevation_unit_id" => nil,
                                       "accuracy_other" => nil, "annotations_old" => nil, "calc_lat_dd" => nil, "calc_lat_dd_old" => nil,
                                       "calc_long_dd" => nil, "calc_long_dd_old" => nil, "collecting_method" => nil, "date_trans" => nil,
                                       "recpermission_id" => nil, "max_depth_in_meters" => nil, "min_depth_in_meters" => nil,
                                       "valid_distribution_flag" => nil, "length_unit_id" => nil, "longitude" => nil,
                                       "latitude" => nil, "label_text" => nil,
                                       'accession_num' => 'ACCESSION #', "coll_end_date_dd" => "COL END DAY",
                                       "coll_end_date_mm" => "COL END MONTH", "coll_end_date_yyyy" => "COLD END YEAR",
                                       "coll_start_date_dd" => "COL START DAY", "coll_start_date_mm" => "COL START MONTH",
                                       "coll_start_date_yyyy" => "COL START YEAR", "collection_number" => "COLLECTION #",
                                       "lat_dd" => "LATITUDE DECIMAL DEGREES", "lat_deg" => "LATITUDE DEGREES",
                                       "lat_dir" => "LATITUDE DIRECTION", "lat_long_rep" => "LOCALITY FORMAT",
                                       "lat_min" => "LATITUDE MINUTES", "lat_sec" => "LATITUDE SECONDS",
                                       "long_dd" => "LONGITUDE DECIMAL DEGREES", "long_deg" => "LONGITUDE DEGREES",
                                       "long_dir" => "LONGITUDE DIRECTION", "long_min" => "LONGITUDE MINUTES",
                                       "long_sec" => "LONGITUDE SECONDS", "verbatim_coll_date" => "VERBATIM COL DATE"}

      @collection_attributes = Collection.column_names

      @collection_option_attributes = Hash.new

      collection_columns_to_change.each do |key|
        @collection_option_attributes[key[0]]= key[1] unless collection_columns_to_change[key[0]] == nil
      end

      @collection_attributes.each do |column|
        if collection_columns_to_change.has_key?(column) == false && column.include?("_")
          label = column.upcase.gsub!('_', ' ') #unless collection_columns_to_change[column] == nil
        elsif collection_columns_to_change.has_key?(column) == true && column.include?("_")
          label = collection_columns_to_change[column]
        elsif collection_columns_to_change.has_key?(column) == false
          label = column.upcase
        end
        if label
          @collection_option_attributes[column] = label unless @collection_option_attributes.has_key?(column)
        else
          @collection_option_attributes.delete(column)
        end
      end
      ordered_hash = Hash.new
      @collection_option_attributes.sort.each do |deep_hash|
        ordered_hash[deep_hash[0]] = deep_hash[1]
      end

      @collection_option_attributes = ordered_hash

      @created_custom_mappings = current_project.custom_mappings.where('user_id = ?', current_user.user_id)

      respond_to do |format|
        format.json { render :json => { :created_custom_mappings => @created_custom_mappings, :taxonomy => @taxon_option_attributes, :collection => @collection_option_attributes}, :content_type => 'application/json' }
      end
    end
  end

  def index
    #render text: "hello", layout: true

    @bulk_upload = current_project.collections.new
    render 'index', :layout => true
  end

  def create
    file_post = Collections::BulkUpload.save_bulk_upload_xls_file(params[:bulk_upload][:bulk_upload_file], params[:upload_type])
    file_name = params[:bulk_upload][:bulk_upload_file].original_filename
    file_path = "#{Rails.root}/private/files/#{params[:upload_type]}/bulk_uploads_temp_files/#{params[:bulk_upload][:bulk_upload_file].original_filename}"
    xls = Excel.new(file_path)
    xls.to_csv("#{Rails.root}/private/files/#{params[:upload_type]}/bulk_uploads_temp_files/#{file_name}.csv")
    new_bulk_upload(params, file_name)
  end



  def after_column_mapping

    if params[:save_template_option] == "true"
      save_custom_mapping(params)
    end

    file_name = params[:original_filename]
    collections_migration(params)

    File.delete("#{Rails.root}/private/files/collections/bulk_uploads_temp_files/#{file_name}.csv")
    File.delete("#{Rails.root}/private/files/collections/bulk_uploads_temp_files/#{file_name}")
  end

  def download_bulk_upload_templates
    send_file("#{Rails.root}/private/files/templates/#{params[:template_type]}_bulk_upload_template.xls", :disposition => 'attachment')
  end

  def template_column_mapping

  end

  def old_new_template

    taxon = passkey.unlock(Taxon)
    @taxon_template_columns = taxon.column_names.to_a

    taxon_columns_to_remove = ["taxon_id", "rtid", "vtid", "owner_user_id", "owner_record_rtid",
                               "owner_graph_rtid", "owner_permission_set_rtid", "creator_rtid", "created_at", "updater_rtid",
                               "updated_at", "old_tolkin_id", "old_accepted_name", "has_children", "deleted_at", "ubio_id",
                               "ncbi_id", "treebase_id", "copied_from_id", "type_date"]

    taxon_columns_to_remove.each do |c|
      @taxon_template_columns.delete(c.to_s)
    end

    @collection_template_columns = Collection.column_names.to_a

    collection_columns_to_remove = ["id", "coll_start_date", "coll_end_date", "taxon_id", "last_updated_by", "user_id",
                                    "project_id", "created_at", "updated_at", "long_min_old", "long_sec_old", "long_degree_old",
                                    "lat_min_old", "lat_sec_old", "lat_degree_old", "higher_geography", "continent", "image_url",
                                    "guid", "old_tolkin_id", "copied_from_id", "lat_degree_old", "higher_geography", "continent", "image_url"]

    collection_columns_to_remove.each do |c|
      @collection_template_columns.delete(c.to_s)
    end


    @collection_template_columns << ["coll_start_date_dd", "coll_start_date_mm", "coll_start_date_yyyy", "coll_end_date_dd",
                                     "coll_end_date_mm", "coll_end_date_yyyy", "elevation_unit", "lat_deg",
                                     "lat_min", "lat_sec", "lat_direction", "lat_decimal_degrees",
                                     "long_deg", "long_min", "long_sec", "long_direction", "long_decimal_degrees"]#, "", "", "", "", "", "", ""]

    @collection_template_columns.flatten!
    @taxon_template_columns.flatten!

    @collection_template_columns.sort!
    @taxon_template_columns.sort!

    respond_to do |format|
      format.html { render :partial => 'new_template', :layout => false }
    end

  end

  def get_custom_mapping

    map = current_project.custom_mappings.where(' name = ?', params[:map_name])
    @loaded_map = Marshal.load(Base64.decode64(map.first.map))
    respond_to do |format|
      format.json { render :json => { :loaded_map => @loaded_map }, :content_type => 'application/json' }
    end
  end

  def download_template
    send_file("#{Rails.root}/private/files/templates/#{params[:template_type]}_bulk_upload_template.xls", :disposition => 'attachment')

  end

  private

  def save_custom_mapping(params)

    map_object = array_to_custom_map_hash(params[:custom_template_mapping])

    mapping = {
        :name => params[:mapping_save_name],
        :map => Base64.encode64(Marshal.dump(map_object)),
        :user_id => current_user.user_id,
        :project_id => current_project.owner_graph_rtid
    }
    @created_custom_mapping = CustomMapping .create!(mapping)
  end

  def array_to_hash(array)
    count = 0
    hash = Hash.new
    (array.length / 2).times do
      hash[array[count]] = array[count+1]
      count += 2
    end
    return hash
  end

  def array_to_custom_map_hash(array)
    count = 0
    hash2 = Hash.new
    (array.length / 3).times do
      (1).times do
        hash1 = Hash.new
        hash1[array[count+1]] = array[count+2]
        hash2[array[count]] = hash1
      end
      count += 3
    end
    return hash2
  end

  def create_taxa(name, author, infra_author, infra_name)
    tax = { :name => name,
            :author => author,
            :infra_author => infra_author,
            :infra_name => infra_name,
            :owner_graph_rtid => current_project.owner_graph_rtid}
    taxon = @unlocked_taxonomies.create!(tax)

    return taxon

  end

  def type_statuses
    [ [ '', 'none' ],
      [ 'Holotype', 'holotype' ],
      [ 'Isotype', 'isotype' ],
      [ 'Neotype', 'neotype' ],
      [ 'Lectotype', 'lectotype' ],
      [ 'Isolectotype', 'isolectotype' ],
      [ 'Syntype', 'syntype' ],
      [ 'Isosyntype', 'isosyntype' ],
      [ 'Paratype', 'paratype' ],
      [ 'Isoparatype', 'isoparatype' ],
      [ 'Isoneotype', 'isoneotype'],
      [ 'Non est Typus', 'non_est_typus' ],
      [ 'Type', 'type' ]
    ]
  end

  def file_validation(params)
#-----------------------------------------------------------------------------------------------------------------------
#File Validation
#Taxon: Must exist in DB
#Type Status: Must exist in Current List
#Collector: Required
#-----------------------------------------------------------------------------------------------------------------------
    @unlocked_taxonomies = passkey.unlock(Taxon)
      validation_row_counter = 0
      error_rows = []
      @created_taxonomies = []
      @errors =[]
     
      if params[:create_taxa] == "true"
        CSV.foreach(@csv_file_path, :headers => :first_row, :row_sep => :auto) do |row|
          #CSV.foreach(@csv_file_path, :headers => :first_row, :row_sep => :auto, :header_converters => :symbol) do |row|
          error_rows = validation_row_counter + 1
          error_descriptions = []
          attrs = row.to_hash

          mapped_taxonomy_attributes = array_to_hash(params[:taxonomy_column_value2])
          mapped_collection_attributes = array_to_hash(params[:collection_column_value2])

          taxon_name = attrs[mapped_taxonomy_attributes.key('name')]
          author = attrs[mapped_taxonomy_attributes.key('author')]
          infra_author = attrs[mapped_taxonomy_attributes.key('infra_author')]
          infra_name = attrs[mapped_taxonomy_attributes.key('infra_name')]
          type_status = attrs[mapped_taxonomy_attributes.key('type_status')]
          collector = attrs[mapped_taxonomy_attributes.key('collector')]

          val_taxon = @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ? and infra_name = ?',current_project.owner_graph_rtid, taxon_name, author, infra_author, infra_name).empty? &&
              @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ?',current_project.owner_graph_rtid, taxon_name, author, infra_author).empty? &&
              @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ?',current_project.owner_graph_rtid, taxon_name, author).empty? &&
              @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ?',current_project.owner_graph_rtid, taxon_name).empty?
          #val_taxon ? error_descriptions << "Taxonomy with Taxon Name: '#{attrs[:taxon_name]}', Author: '#{attrs[:author]}', Infra Name: '#{attrs[:infra_name]}' and Infra Author: '#{attrs[:infra_author]}' does not exist" : :ok
          val_taxon ? @created_taxonomies << create_taxa(taxon_name, author, infra_author, infra_name) : :ok
          #type_status = attrs[:type_status].to_s
          #type_statuses.flatten.include?(type_status) ? :ok : error_descriptions << "Type Status not in list"
          #collector = attrs[:collector]
          #collector.nil? ? error_descriptions << "Collector can't be blank" : :ok
          @errors << [error_rows, error_descriptions]
          validation_row_counter = validation_row_counter + 1

        end
      else
        CSV.foreach(@csv_file_path, :headers => :first_row, :row_sep => :auto) do |row|
          #CSV.foreach(@csv_file_path, :headers => :first_row, :row_sep => :auto, :header_converters => :symbol) do |row|
          error_rows = validation_row_counter + 1
          error_descriptions = []
          attrs = row.to_hash
          #taxon_name = attrs[:taxon_name].to_s

          mapped_taxonomy_attributes = array_to_hash(params[:taxonomy_column_value2])
          mapped_collection_attributes = array_to_hash(params[:collection_column_value2])
          #mapped_taxonomy_attributes.symbolize_keys!
          #mapped_collection_attributes.symbolize_keys!

          taxon_name = attrs[mapped_taxonomy_attributes.key('name')]
          author = attrs[mapped_taxonomy_attributes.key('author')]
          infra_author = attrs[mapped_taxonomy_attributes.key('infra_author')]
          infra_name = attrs[mapped_taxonomy_attributes.key('infra_name')]
          type_status = attrs[mapped_taxonomy_attributes.key('type_status')]
          collector = attrs[mapped_taxonomy_attributes.key('collector')]

          val_taxon = @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ? and infra_name = ?',current_project.owner_graph_rtid, taxon_name, author, infra_author, infra_name).empty? &&
              @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ?',current_project.owner_graph_rtid, taxon_name, author, infra_author).empty? &&
              @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ?',current_project.owner_graph_rtid, taxon_name, author).empty? &&
              @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ?',current_project.owner_graph_rtid, taxon_name).empty?
          val_taxon ? error_descriptions << "Taxonomy with Taxon Name: '#{taxon_name}', Author: '#{author}', Infra Name: '#{infra_name}' and Infra Author: '#{infra_author}' does not exist" : :ok
          #type_status = attrs[:type_status].to_s
          #type_statuses.flatten.include?(type_status) ? :ok : error_descriptions << "Type Status not in list"
          #collector = attrs[:collector]
          #collector.nil? ? error_descriptions << "Collector can't be blank" : :ok
          @errors << [error_rows, error_descriptions]
          validation_row_counter = validation_row_counter + 1
        end
      end

      @errors_exist = nil

      @errors_flattened = @errors.flatten
      @errors_flattened.each do |element|
        if element.to_s.include? 'does not exist'
          @errors_exist = true
        end
      end
  end

  def collections_migration(params)
    current_project.collections.transaction do

      @csv_file_path = params[:csv_file_path]
      
      file_validation(params)
#-----------------------------------------------------------------------------------------------------------------------
#File Validation Completed
#-----------------------------------------------------------------------------------------------------------------------
      if @errors_exist.nil?
#-----------------------------------------------------------------------------------------------------------------------
#Migration Transaction Begin
#-----------------------------------------------------------------------------------------------------------------------
        current_project.collections.transaction do
          counter = 0
          inserted = 0
          latlong = 0

          @imported_collections = []

          CSV.foreach(@csv_file_path, :headers => :first_row, :row_sep => :auto) do |row|
            counter = counter + 1
            col = row.to_hash

            mapped_taxonomy_attributes = array_to_hash(params[:taxonomy_column_value2])
            mapped_collection_attributes = array_to_hash(params[:collection_column_value2])

            taxname = col[mapped_taxonomy_attributes.key('name')]
            taxauth = col[mapped_taxonomy_attributes.key('author')]
            tax_inf_auth = col[mapped_taxonomy_attributes.key('infra_author')]
            tax_inf_name = col[mapped_taxonomy_attributes.key('infra_name')]
            type_status = col[mapped_collection_attributes.key('type_status')]
            collector = col[mapped_collection_attributes.key('collector')]

            #get taxon
            taxon =
                @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ? and infra_name = ?', current_project.owner_graph_rtid, taxname, taxauth, tax_inf_auth, tax_inf_name)[0] ||
                    @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ?', current_project.owner_graph_rtid, taxname, taxauth, tax_inf_auth)[0] ||
                    @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ? and author = ?', current_project.owner_graph_rtid, taxname, taxauth)[0] ||
                    @unlocked_taxonomies.where('owner_graph_rtid = ? and name = ?', current_project.owner_graph_rtid, taxname)[0]

            unless taxon.nil?
              col[:taxon] = taxon
              date = col[mapped_collection_attributes.key('col_start_date_yyyy')].to_s + "-" + col[mapped_collection_attributes.key('col_start_date_mm')].to_s + "-" + col[mapped_collection_attributes.key('col_start_date_dd')].to_s
              col[:coll_start_date] = date unless date.length < 10

              enddate = col[mapped_collection_attributes.key('col_end_date_yyyy')].to_s + "-" + col[mapped_collection_attributes.key('col_end_date_mm')].to_s + "-" + col[mapped_collection_attributes.key('col_end_date_dd')].to_s unless col[mapped_collection_attributes.key('col_end_date_dd')].nil?
              if enddate then (col[:coll_end_date] = enddate unless enddate.length < 10) end

              if col[mapped_collection_attributes.key('notes')].nil?
                col[mapped_collection_attributes.key('notes')] = col[mapped_collection_attributes.key('plant_description')].to_s
              else
                unless col[mapped_collection_attributes.key('plant_description')].nil?
                  col[mapped_collection_attributes.key('notes')] = col[mapped_collection_attributes.key('notes')].to_s + " ; " + col[mapped_collection_attributes.key('plant_description')].to_s
                end
              end

              col.delete(mapped_collection_attributes.key('accession_num'))
              #col.delete(mapped_collection_attributes.key('plant_description'))
              col.delete(mapped_collection_attributes.key('coll_date_yyyy'))
              col.delete(mapped_collection_attributes.key('coll_date_mm'))
              col.delete(mapped_collection_attributes.key('coll_date_dd'))
              col.delete(mapped_taxonomy_attributes.key('name'))
              col.delete(mapped_taxonomy_attributes.key('author'))
              col.delete(mapped_taxonomy_attributes.key('infra_name'))
              col.delete(mapped_taxonomy_attributes.key('infra_author'))
              col.delete(mapped_collection_attributes.key('coll_start_date_yyyy'))
              col.delete(mapped_collection_attributes.key('coll_start_date_dd'))
              col.delete(mapped_collection_attributes.key('coll_start_date_mm'))
              col.delete(mapped_collection_attributes.key('coll_end_date_yyyy'))
              col.delete(mapped_collection_attributes.key('coll_end_date_dd'))
              col.delete(mapped_collection_attributes.key('coll_end_date_mm'))
              col[:recpermission_id] = "2"
              col[:project_id] = Project.where("project_id = ?", current_project)[0]
              col[:user] = User.where("user_id = ?", current_user)[0]
              col[mapped_collection_attributes.key('long_dir')].downcase unless col[mapped_collection_attributes.key('long_dir')].nil?
              col[mapped_collection_attributes.key('lat_dir')].downcase unless col[mapped_collection_attributes.key('lat_dir')].nil?
              col[:lat_long_rep] = (col.has_key?(mapped_collection_attributes['lat_dd']) ? 'DD' : 'DMS')
              if col[:lat_long_rep] == 'DMS'
                calclat = col[mapped_collection_attributes.key('lat_deg')].to_f + (col[mapped_collection_attributes.key('lat_min')].to_f / 60) + (col[mapped_collection_attributes.key('lat_sec')].to_f / 3600)
                calclat = -calclat if col[mapped_collection_attributes.key('lat_dir')] == 's'
                calclong = col[mapped_collection_attributes.key('long_deg')].to_f + (col[mapped_collection_attributes.key('long_min')].to_f / 60) + (col[mapped_collection_attributes.key('long_sec')].to_f / 3600)
                calclong = -calclong if col[mapped_collection_attributes.key('long_dir')] == 'w'
                col[:calc_lat_dd], col[:calc_long_dd] = calclat, calclong
                latlong = latlong + 1
              end
              col[:elevation_unit_id] = LengthUnit.where('name = ?', col[mapped_collection_attributes.key('elevation_unit')]).first[:id].to_i unless col[mapped_collection_attributes.key('elevation_unit')].nil?
              col.delete(mapped_collection_attributes.key('elevation_unit'))
              col[mapped_collection_attributes.key('long_dir')].downcase! unless col[mapped_collection_attributes.key('long_dir')].nil?
              col[mapped_collection_attributes.key('lat_dir')].downcase! unless col[mapped_collection_attributes.key('lat_dir')].nil?
              col.delete(mapped_collection_attributes.key('lat_dir'))
              col.delete(mapped_collection_attributes.key('long_dir'))
              #col.delete(mapped_collection_attributes.key('long_dd'))
              #col.delete(mapped_collection_attributes.key('lat_dd'))
              inserted = inserted + 1

              attrs = {"accession_num" => col[mapped_collection_attributes.key('accession_num')],
                       "accuracy" => col[mapped_collection_attributes.key('accuracy')],
                       "associate_collectors" => col[mapped_collection_attributes.key('associate_collectors')],
                       "barcode" => col[mapped_collection_attributes.key('barcode')],
                       #"coll_end_date_dd" => col[mapped_collection_attributes.key('coll_end_date_dd')],
                       #"coll_end_date_mm" => col[mapped_collection_attributes.key('coll_end_date_mm')],
                       #"coll_end_date_yyyy" => col[mapped_collection_attributes.key('coll_end_date_yyyy')],
                       #"coll_start_date_dd" => col[mapped_collection_attributes.key('coll_start_date_dd')],
                       #"coll_start_date_mm" => col[mapped_collection_attributes.key('coll_start_date_mm')],
                       #"coll_start_date_yyyy" => col[mapped_collection_attributes.key('coll_start_date_yyyy')],
                       "collection_number" => col[mapped_collection_attributes.key('collection_number')],
                       "collector" => col[mapped_collection_attributes.key('collector')],
                       "country" => col[mapped_collection_attributes.key('country')],
                       "county" => col[mapped_collection_attributes.key('county')],
                       "elevation_end" => col[mapped_collection_attributes.key('elevation_end')],
                       "elevation_start" => col[mapped_collection_attributes.key('elevation_start')],
                       #"elevation_unit" => col[mapped_collection_attributes.key('elevation_unit')],
                       "flowering" => col[mapped_collection_attributes.key('flowering')],
                       "fruiting" => col[mapped_collection_attributes.key('fruiting')],
                       "geology" => col[mapped_collection_attributes.key('geology')],
                       "identification_qualifier" => col[mapped_collection_attributes.key('identification_qualifier')],
                       "institution_code" => col[mapped_collection_attributes.key('institution_code')],
                       "island" => col[mapped_collection_attributes.key('island')],
                       "lat_dd" => col[mapped_collection_attributes.key('lat_dd')],
                       "lat_deg" => col[mapped_collection_attributes.key('lat_deg')],
                       "lat_dir" => col[mapped_collection_attributes.key('lat_dir')],
                       "lat_long_rep" => 'DD',#col['lat_long_rep'],fix this (column uses enum type!!)
                       "lat_min" => col[mapped_collection_attributes.key('lat_min')],
                       "lat_sec" => col[mapped_collection_attributes.key('lat_sec')],
                       "locality" => col[mapped_collection_attributes.key('locality')],
                       "long_dd" => col[mapped_collection_attributes.key('long_dd')],
                       "long_deg" => col[mapped_collection_attributes.key('long_deg')],
                       "long_dir" => col[mapped_collection_attributes.key('long_dir')],
                       "long_min" => col[mapped_collection_attributes.key('long_min')],
                       "long_sec" => col[mapped_collection_attributes.key('long_sec')],
                       "notes" => col[mapped_collection_attributes.key('notes')],
                       "plant_description" => col[mapped_collection_attributes.key('plant_description')],
                       "prefix" => col[mapped_collection_attributes.key('prefix')],
                       "silica_sample" => col[mapped_collection_attributes.key('silica_sample')],
                       "source_url" => col[mapped_collection_attributes.key('source_url')],
                       "state_province" => col[mapped_collection_attributes.key('state_province')],
                       "suffix" => col[mapped_collection_attributes.key('suffix')],
                       "type_name" => col[mapped_collection_attributes.key('type_name')],
                       "type_status" => col[mapped_collection_attributes.key('type_status')],
                       "vegetation" => col[mapped_collection_attributes.key('vegetation')],
                       "verbatim_coll_date" => col[mapped_collection_attributes.key('verbatim_coll_date')],
                       "taxon_id" => taxon.id}
              attrs.symbolize_keys!

              attrs[:recpermission_id] = "2"
              attrs[:project_id] = Project.where("project_id = ?", current_project)[0]
              attrs[:user] = User.where("user_id = ?", current_user)[0]
              attrs[:elevation_unit_id] = LengthUnit.where('name = ?', col[mapped_collection_attributes.key('elevation_unit')]).first[:id].to_i unless col[mapped_collection_attributes.key('elevation_unit')].nil?
              attrs[:coll_start_date] = date unless date.length < 10

              if enddate then (attrs[:coll_end_date] = enddate unless enddate.length < 10) end

              begin
                Collection.create!(attrs)
              rescue Exception => e
                render :text => "#{e}", :status => 500
                return
              end

              if @created_taxonomies
                @imported_collections << [counter, col[mapped_collection_attributes.key('collection_number')], taxon.name ]
              else
                @imported_collections << [counter, col[mapped_collection_attributes.key('collection_number')] ]
              end
            end
          end
        end

        respond_to do |format|
          format.html { render :partial => "collections_bulk_upload_end_report.html.erb", :layout => false }
        end
#-----------------------------------------------------------------------------------------------------------------------
#Migration Transaction End
#-----------------------------------------------------------------------------------------------------------------------
      else

        respond_to do |format|
          format.html { render :partial => "collections_bulk_upload_end_report.html.erb", :layout => false }
        end
      end
    end
  end

end
