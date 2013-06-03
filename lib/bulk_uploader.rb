module BulkUploader
  require 'csv'
  require 'spreadsheet'

  def show_new_upload type
    @resource = type
    @new_upload_path_string = "new_upload_project_" + pathify(@resource) + "_path"
    render '/shared/bulk_uploads/show_new_upload.html.haml', layout: request.xhr? ? false : true
  end

  def new_upload type
    @uploaded_file = { :dir  => user_dir(type),
                       :file => params[:file]['file'],
                       :name => params[:file]['file'].original_filename,
                       :type => type }
    store_file(type)
    @custom_mappings = current_user.custom_mappings.for_module(@uploaded_file[:type])
    @uploaded_file[:headers] = CSV.read(@uploaded_file[:path], {:headers => true}).headers
    @tolkin_headers = @uploaded_file[:type].column_names.delete_if{ |col|
      unwanted_columns.include?(col.to_s) ||
        (col.to_s.end_with?('_id') unless %w(scaffold_id ubio_id ncbi_id treebase_id).include?(col.to_s)) ||
        col.to_s.end_with?('_old') ||
        col.to_s.end_with?('_rtid')
    }
    @form_path = "bulk_upload_project_" + pathify(@uploaded_file[:type]) + "_path"
    @taxon = true if type.has_column?("taxon_id") unless type == Taxon
    render '/shared/bulk_uploads/new_upload.html.haml', layout: request.xhr? ? false : true
  end

  def pathify resource
    resource.to_s.downcase.pluralize.split('::').join('_')
  end

  def view_map
    @map = CustomMapping.find(params[:map_id])
    render :partial => '/shared/bulk_uploads/view_map.html.haml'
  end


  def bulk_upload type
    columns_map = {}
    taxon_map = {}
    if params[:type] == 'new'
      columns_map = JSON.parse(params[:map])
      #save custom map
      CustomMapping.create!({
        :user => current_user,
        :project => current_project,
        :type => type.to_s,
        :name => params[:name],
        :mapping => columns_map.to_json })
    else
      columns_map = CustomMapping.find(params[:map_id]).map_hash
    end
    columns_map.each do |k,v|
      match = v.match(/(?<=taxon\[)[a-zA-Z_]+/) #match the taxon attributes and move from columns_map to taxon_map
      if !match.nil?
        taxon_map[k] = match[0]
        columns_map.delete(k)
      elsif v == ""
        if type.has_column?(k)
          columns_map[k] = k #use columns that have the same name
        elsif type.has_column?(k.downcase)
          columns_map[k] = k.downcase
        else
          columns_map.delete(k) #delete columns that don't match
        end
      end
    end
    #open file
    path = user_dir(type.to_s) + '/' + params[:filename]
    objects = []
    index,@count,@success = 0,0,0
    @instance_errors = []
    bulk_upload_filename = BulkUploadFilename.create!({
      :filename => params[:filename],
      :date => DateTime.now.utc,
      :project => current_project,
      :record_model => type.to_s
                               })
    CSV.foreach(path, :headers => :first_row, :row_sep => :auto) do |row|
      #change headers
      is_tax = params[:taxon] == "true" && !taxon_map.empty?
      entry_attrs = {}
      taxon_attrs = {}
      row.to_hash.each{|k,v|
        entry_attrs[columns_map[k]] = v if columns_map.has_key?(k)
        taxon_attrs[taxon_map[k]]   = v if taxon_map.has_key?(k) && is_tax
      }
      #entry = Hash[row.to_hash.map{ |k,v| [columns_map[k] || k, v] }]
      #make new object
      object, taxon = '',''
      begin
        object = type.new(entry_attrs)
      rescue => e
        object = e.to_s
      end
      if is_tax
        begin
          taxon = find_taxon_by_attributes(taxon_attrs) ##TODO: OR CREATE?????
          if taxon.new_record?
            taxon.save!
            bulk_upload_filename.bulk_upload_records << BulkUploadRecord.create({:record_id => taxon.taxon_id, :is_taxon => true})
          end
        rescue => e
          taxon = e.to_s
        end
      end
      if object.class == String || (is_tax && taxon.class == String)
        @instance_errors.push({:index => index, :object => object, :taxon => taxon, :row => row.to_hash})
      else
        @success +=1
      end
      objects.push(is_tax ? [object, taxon] : object)
      index += 1
      @count += 1
    end

    #save objects one by one, push errors into an array
    @saving_errors = []
    objects.each_with_index do |object,index|
      begin
        new_obj = object
        if object.class == Array
          new_obj, taxon = object.first, object.second
          new_obj.taxon = taxon
        end
        new_obj.project = current_project if new_obj.respond_to?(:project)
        new_obj.user = current_user if new_obj.respond_to?(:user)
        new_obj.recpermission_id = 1 if new_obj.respond_to?(:recpermission_id)
        if new_obj.save!
          bulk_upload_filename.bulk_upload_records << BulkUploadRecord.create({:record_id => new_obj.id, :is_taxon => false})
        end
      rescue => e
        @saving_errors.push({:index => index, :error => e.to_s, :entry => object})
      end
    end
    #display error report (flash with redirect? or new page)
    #DELETE FILE
    File.delete(path)
    #redirect to index
    #debugger unless @saving_errors.empty? and @instance_errors.empty?
    unless @saving_errors.empty? and @instance_errors.empty?
      render '/shared/bulk_uploads/show_errors.html.haml', layout: request.xhr? ? false : true
    else
      head :ok
    end
  end

  def save_entry type, entry
    #debugger
    'test'
  end

  def store_file(type)
    split_dir = @uploaded_file[:dir].split('/')
    split_dir.each_with_index{|folder,i| Dir.mkdir(split_dir[0..i].join('/'),0775) unless Dir.exists?(File.join(*split_dir[0..i])) }
    @uploaded_file[:path] = File.join(@uploaded_file[:dir],@uploaded_file[:name])
    File.open(@uploaded_file[:path], "wb"){|f| f.write(@uploaded_file[:file].read) }
  end

  def map_columns mapping_hash
    #insert map hash into database (text of hash)
  end

  def has_map_for_user?
    user = current_user
    #check if map exists for module and user
  end

  def find_taxon_by_attributes(attrs)
    taxa = passkey.unlock(Taxon)
    taxon = taxa.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ? and infra_name = ?', current_project.owner_graph_rtid, attrs["name"], attrs["author"], attrs["infra_author"], attrs["infra_name"])[0] ||
      taxa.where('owner_graph_rtid = ? and name = ? and author = ? and infra_author = ?', current_project.owner_graph_rtid, attrs["name"], attrs["author"], attrs["infra_author"])[0] ||
      taxa.where('owner_graph_rtid = ? and name = ? and author = ?', current_project.owner_graph_rtid, attrs["name"], attrs["author"])[0] ||
      taxa.where('owner_graph_rtid = ? and name = ? and infra_author = ?', current_project.owner_graph_rtid, attrs["name"], attrs["infra_author"])[0] ||
      taxa.where('owner_graph_rtid = ? and name = ?', current_project.owner_graph_rtid, attrs["name"])[0]
    taxon || taxa.new(attrs) #todo maybe this create should be a user selectable option?
  end

  def map_for_user
    user = current_user
    #return map for module and user
  end

  def user_dir type
    "private/files/#{type}/temp_bulk/#{current_user.username}"
  end

  def unwanted_columns
    %w(id last_updated_by created_at updated_at deleted_at rtid vtid old_accepted_name has_children updated_on created_on last_updated_by)
  end

end