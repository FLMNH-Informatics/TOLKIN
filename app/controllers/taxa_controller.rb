require "nokogiri" # need hpricot and open-uri
require "open-uri"
require "base64"
class TaxaController < ApplicationController

  helper :application, :forms
  
  include Restful::Responder
  include BulkUploader


  before_filter :params_to_hash

  before_filter :requires_selected_project, :except => [ :auto_complete_for_taxon_name ]
  before_filter :requires_project_guest, :only => [ :findchildren, :fetchchildren, :tree_view,
    :taxon_details ]
  before_filter :requires_project_updater, :only => [ :new, :create, :save_taxon_accepted_name,
    :update, :renumberall, :move_to, :destroy, :destroy_multiple, :delete_selected ]
  skip_before_filter :requires_any_guest, :only => [ :index, :show ]
  
  #  before_filter :check_record_permission, :except=> [ :tree_view, :species_page, :index, :create, :findchildren, :fetchchildren, :taxon_details,
  #    :citation_add, :delete_citation, :auto_complete_for_taxon_name, :destroy_multiple, :show_add_to_otu, :delete_selected, :add_to_otu, :auto_complete_for_otu_name, :new ,:treebase_search, :ubio_search, :ubio_retrieve_taxon_details , :ncbi_search, :ncbi_retrieve_taxon_details, :load_citation_search_widget, :citation_insert , :new_citation_for_taxonomy , :citaion_type_selection , :export_csv , :display_taxa_column_names]
  
  
  #  before_filter :find_project, :only=> [:create, :taxon_details, :citation_add, :get_morphology_references, :new_citation_for_taxonomy]
  #before_filter :new_taxon, :only=>[:create]
  before_filter :find_taxon, :only=>[:move_to, :citation_add, :new_citation_for_taxonomy]
  before_filter :begin_search, :only => [:search_treebase,:search_ubio,:search_ncbi]
  #before_filter :assign_other_information, :only=>[:create]
  skip_before_filter :requires_any_guest, :only => [:add_protologue]
  # for the move control field
  auto_complete_for :taxon, :name, :project_scope => true
  auto_complete_for :otu, :name, :project_scope => true
  
  #  Taxon.content_columns.each do |column|
  #    if column.name.downcase != "vectors"
  #      in_place_edit_for :taxon, column.name
  #    end
  #  end
  #
  #  Collection.content_columns.each do |column|
  #    in_place_edit_for :collection, column.name
  #  end

  def show_new_upload
    super resource
  end

  def new_upload
    super resource
  end

  def begin_upload
    super resource
  end

  def bulk_upload
    super resource
  end

  def view_map
    super
  end

  def resource
    Taxon
  end

  def create
    params[:taxon].each do |k,v|
      params[:taxon][k] = [*params[:taxon][k]].first
    end
    params[:taxon][:description]=params[:taxon][:description].gsub("\n","<br/>")
    params[:taxon][:notes]=params[:taxon][:notes].gsub("\n","<br/>")
    params[:taxon][:owner_permission_set_rtid] = params[:permissions][:permission_set_rtid]

    #    params[:taxon][:project_id] = @current_project.id
    #    params[:taxon][:updater_id] = @current_user.id
    #    params[:taxon][:creator_id] = @current_user.id
    #    @taxon = Taxon.new(params[:taxon])


    @taxon = Taxon.create(params[:taxon])
    @taxon.citations = Library::Citation.find(params[:citation_ids]) if params[:citation_ids]
    #following code creates an OTU with the same name as the taxon, to be used in morph>matrices
    #it was moved into the taxa model after_create callback
    #@otu = Otu.new
    #@otu.name, @otu.project_id, @otu.creator_id = @taxon.name, current_project.project_id, current_user.user_id
    #@otu.save!
    #@otu.taxa << @taxon

    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: { id: @taxon.id } }
    end
  end

  def list
    if params[:starts_with]
      term = params[:starts_with]
    else
      term = 'a'
    end
    @taxon = passkey.unlock(Taxon).select('DISTINCT ("taxa"."name"), "taxa".* ').where("name iLIKE ?","#{term}%").order(:name)

    render 'list'
  end

  def render_permission_denied
    render :update do
      |page| page['notice'].value = flash[:notice].to_s
    end
  end

  #  def collections
  #    respond_to_index_request_searchlogic(@current_project.taxa.find(params[:id]).collections)
  #  end

  def set_permissions
    
    begin
      Taxon.transaction do
        # prepares taxa fetching params

        params.merge!(JSON.parse(params[:json_finder_params], { symbolize_names: true }))
        @resource = passkey.unlock(Taxon)
        validate(params) && parse(params)
        finder_params = prepare(params, :for => :finder)

        #fetches taxa to be permitted, getting list of both permitted and unpermitted so warning can be given if taxa are selected that can't be permitted
        unpermitted_result = (@resource = passkey.unlock(Taxon)).scoped.apply_finder_options(finder_params)
        #fail UserError, "no taxa selected" if unpermitted_result.empty?
        permitted_result = (@resource = passkey.unlock(Taxon, to: 'permit')).apply_finder_options(finder_params)
        if unpermitted_result.size != permitted_result.size
          fail UserError, "user not permitted to permit: #{
          (unpermitted_result - permitted_result).collect{|taxon| taxon.label}.join(', ')
          }"
        end

        # get helpful info
        pset_view_rtid = admin_passkey.unlock(PermissionSet).where(:label =~ 'View%').first.rtid # FIXME: this will only work until user can dynamically set psets
        all_roles = passkey.unlock(Role).order(:rtid)
        #        unless params[:permissions][:permission_set_rtid].blank?
        # old_pset_rtid is permission_set that all taxa belong to / have been set to, if all taxa belong to same permission set
        old_pset_rtid = params[:permissions][:permission_set_rtid]
        !old_pset_rtid.blank? && (
          permissions =
            passkey.unlock(Permission).apply_finder_options(
            conditions: { permission_set_rtid: old_pset_rtid },
            order: :role_rtid
          )
        )


        # one permission set for all taxa and permissions matrix/table hasn't been modified
        if !old_pset_rtid.blank? && perm_selections_match?(params[:permissions][:role], permissions.all, all_roles)
          #FIXME: if only one taxon selected and taxon pset doesn't have a label, this error might be raised anyways
          unless params[:permissions][:permission_set_label].blank?
            fail UserError, "provided label for set of already labeled permissions"
          else
            # sets every taxon as belonging to same permission set
            permitted_result.each do |taxon|
              taxon = passkey.unlock(Taxon).select(['taxon_id', 'owner_permission_set_rtid']).find(taxon.taxon_id, readonly: false)
              taxon.update_attributes!(owner_permission_set_rtid: params[:permissions][:permission_set_rtid])
            end
          end
        else
          # check to see if label provided for permissions set / permission matrix hasn't already been taken, create pset
          unless params[:permissions][:permissions_set_label].blank?
            unless admin_passkey.unlock(PermissionSet).find_by_label(params[:permissions][:permission_set_label])
              pset =
                PermissionSet.create!(
                owner_permission_set_rtid: pset_view_rtid,
                label: params[:permissions][:permission_set_label]
              )
              pset = passkey.unlock(PermissionSet).find(pset.permission_set_id)

              # create permission set
            else
              fail UserError, "set of permissions labeled '#{params[:permissions][:permission_set_label]}' already exists"
            end
          else
            # if no label provided, no need to check for naming collisions with previous psets, just create pset
            pset =
              PermissionSet.create!(
              owner_permission_set_rtid: pset_view_rtid
            )
            pset = passkey.unlock(PermissionSet).find(pset.permission_set_id)
          end

          # for every role in project, set permissions on pset appropriately according to table checkbox values
          all_roles.each do |role|
            Permission.create!(
              permission_set_rtid: pset.rtid,
              role_rtid: role.rtid,
              owner_permission_set_rtid: pset_view_rtid,
              visible: !!params[:permissions][:role][role.rtid.to_s].try(:[],'visible'),
              editable: !!params[:permissions][:role][role.rtid.to_s].try(:[],'editable'),
              deletable: !!params[:permissions][:role][role.rtid.to_s].try(:[],'deletable'),
              permissible: !!params[:permissions][:role][role.rtid.to_s].try(:[],'permissible')
            )
          end
          # assign permission set to every taxon in collection
          permitted_result.each do |taxon|
            taxon = passkey.unlock(Taxon).find(taxon.taxon_id, readonly: false) # need to get non-readonly copy to modify
            taxon.update_attributes!(owner_permission_set_rtid: pset.rtid)
          end
          #          end
        end
      end
      head :ok
    rescue => e
      head 400
    end
  end

  def set_permissions_view
    begin
      @json_finder_params = params.select{|k,v| ['select', 'conditions', 'joins'].include?(k.to_s) }.to_json
      params.merge!(
        select: [ 'taxon_id', 'label', 'owner_permission_set_rtid' ]
      )
      @resource = passkey.unlock(Taxon)
      validate(params) && parse(params)
      finder_params = prepare(params, for: :finder)

        unpermitted_result = (@resource = passkey.unlock(Taxon)).scoped.apply_finder_options(finder_params)
    
        fail UserError, "no taxa selected" if unpermitted_result.empty?
        permitted_result = (@resource = passkey.unlock(Taxon, to: 'permit')).apply_finder_options(finder_params)
        if unpermitted_result.size != permitted_result.size
          fail UserError, "user not permitted to permit: #{
          (unpermitted_result - permitted_result).collect{|taxon| taxon.label}.join(', ')
        }"
        end
        @taxa = permitted_result
        #          if @taxa.count > 0
        if params[:permission_set_rtid].blank?
          @permission_set_rtid = @taxa.first.owner_permission_set_rtid
          @permission_set_rtid = nil unless @taxa.all?{|t| t.owner_permission_set_rtid == @permission_set_rtid }
        else
          @permission_set_rtid = params[:permission_set_rtid].to_i
        end
        #          end
        @all_permission_sets = passkey.unlock(PermissionSet).where(:label ^ nil)
        @roles = passkey.unlock(Role).apply_finder_options({
            include: {
              :permissions => {
                conditions: (:permission_set_rtid + @taxa.collect{|t| t.owner_permission_set_rtid })
              },
              :permissions_2 => {
                conditions: { permission_set_rtid: @permission_set_rtid }
              }
            }
          })

        respond_to do |format|
          format.html { render 'set_permissions_view', layout: !request.xhr? }
        end
      rescue => e
        debugger
        respond_to do |format|
          format.html { render text: e, status: 400 }
        end
      end
    end

    def index
      query_params_provided? ||
        params.merge!(
        select: [ 'taxon_id', 'name', 'author', 'infra_author', 'publication',
          'publication_date', 'volume_num', 'pages', 'css_class', 'namestatus_id' ],
        joins: :namestatus.outer,
        include: {
          namestatus: { select: ['id', 'status'] } },
        order: 'name',
        limit: 20
      )

      super(passkey.unlock(Taxon))
      #super(Taxon)
    end

    def tree_view

      selected_tax_entry = session.try(:[], :projects).try(:[], params[:project_id]).try(:[], :cart).try(:[], :current_selection)
      @selected_taxon = (selected_tax_entry.try(:[], :klass) == 'Taxon') && passkey.unlock(Taxon).find(selected_tax_entry[:id])
      @root_taxa = passkey.unlock(Taxon).root
      respond_to do |format|
        format.html
      end
    end

    def new
      @taxon = Taxon.new

      @permission_set_rtid = passkey.unlock(PermissionSet).where(:label =~ 'Delete%').first.rtid

      @all_permission_sets = passkey.unlock(PermissionSet).where(:label ^ nil)
      respond_to do |format|
        format.html { render 'new', layout: request.xhr? ? false : 'application' }
        format.json { render json: @taxon.to_json({ include: [ :namestatus, :collections ]}) }
          
      end
    end
      
    def add_protologue
      if p = ProtologueFile.find_by_taxon_id(params[:id])
        ProtologueFile.destroy(p.id)
      end
      ProtologueFile.transaction do
        file = {}
        file[:protologue] = params[:Filedata]
        file[:taxon_id] = params[:id]
        file[:object_type] = 'protologue'
          
        @proto = ProtologueFile.create!(file)
        render json: @proto
        #head :ok
      end
    end

    def get_protologue
      file = ProtologueFile.find_by_taxon_id(params[:id])
      send_file file.protologue.path, :type => file.protologue_content_type, :disposition => 'attachment'
    end

    def delete_protologue
      if p = ProtologueFile.find_by_taxon_id(params[:id])
        ProtologueFile.destroy(p.id)
      end
      head :ok
    end
      
    def_each :synonyms do |method_name|
      respond_to_has_many_relation_request(current_project.taxa, method_name)
    end

    def show
      query_params_provided? ||
        params.merge!(
        select: [ '*', 'css_class' ],
        include: {
          collections: { select: [ 'id', 'taxon_id', 'collector', 'collection_number', 'country', 'institution_code'],
            limit: 10,
            order: [ 'country', 'collector', 'collection_number' ]
          },
          namestatus: { select: ['id', 'status'] },
          synonyms: {
            select: [ 'taxon_id', 'accepted_name_id', 'label', 'css_class' ],
            include: { namestatus: { select: [ 'id', 'status' ] } },
            order: 'publication_date',
            limit: 10,
          },
          accepted_name: { select: [ 'taxon_id', 'label' ] },
          images: {
            #            select: ['id','attachment_file_name', 'height', 'width']
            #            include: :thumb
          },
          protologue: { select: ['id', 'taxon_id']},
          dna_samples: { select: [ 'id', 'taxon_id', 'sample_type', 'sample_nr' ] },
          sequences: {select: ['id', 'taxon_id', 'markers_fulltext', 'sequence']},
          parent: { select: [ 'taxon_id', 'namestatus_id', 'label' ],
            include: {
              namestatus: { select: [ 'id', 'status' ] }}},
          citations: { select: [ 'id', 'display_name', 'city', 'type', 'publisher_id', 'publication_id' ],
            joins: [ # in array to bypass parsing
              "left join contributorships on (contributorships.position = 1 AND contributorships.citation_id = citations.id)",
              "left join authors on (contributorships.author_id = authors.id)"
            ],
            order: [ 'authors.name' ],
            include: {
              publication: { select: [ 'l_publication_id', 'value', 'publication_type', 'parent_id' ],
                include: {
                  parent: { select: [ 'l_publication_id', 'value', 'publication_type' ] }}},
              contributorships: {
                include: {
                  author: { select: [ 'id', 'name' ] }},
                order: [ 'position' ]},
              publisher: { select: [ 'id', 'name' ] }}}}
      )
      params[:select].push({ except: :notes }) if current_user.public_user? # want this field to be invisible to the public
      super(passkey.unlock(Taxon))
    end
  
    #  def get_species_page
    #    @taxon = current_project.taxa.find(params[:id], :include => [ :namestatus, :creator, :curators, :updater, :accepted_name, :synonyms, :collections, :images, :dna_samples ])
    #
    #    respond_to do |format|
    #      format.html { render :partial => 'species_page', :layout => false }
    #      format.js { render :partial => 'species_page' , :layout => false }
    #      format.xml { render :xml => @taxon.to_xml(:include => [ :namestatus, :creator, :updater, :accepted_name, :synonyms, :collections, :images ] ) }
    #    end
    #  end
  
    def findchildren(index)
      @children=Taxon.find(index).children
    end
  
    def fetch_children
      @callFromFetchChildren=true
      @current, @children = Taxon.fetch_children(params[:id], params[:selected])
      render(:partial=> "node", :object => @current, :layout => false)
    end
  
    #  def taxon_details
    #    @taxon=Taxon.find(params[:id])
    #
    #    # set link destinations for attribute right-hand links
    #    accepted_name_link = @taxon.acceptedname ? project_taxon_path(params[:project_id], @taxon.acceptedname) : nil
    #    basionym_link = @taxon.basionym ? project_taxon_path(params[:project_id], @taxon.basionym) : nil
    #
    #    @general_attributes = [
    #      { :name => :name, :cols => 30 },
    #      { :name => :author },
    #      { :name => :year },
    #      { :name => :namestatus          , :label => 'Name Status'         , :edit_type => :collection, :enum_object => Namestatus, :enum_name_column => 'status' },
    #      { :name => :accepted_name        , :label => 'Accepted Name'       , :edit_type => :autocomplete, :link => accepted_name_link },
    #      { :name => :basionym, :edit_type => :autocomplete, :link => basionym_link },
    #      { :name => :general_distribution }
    #    ]
    #
    #    @more_attributes = [
    #      { :name => :commonname   , :label => 'Common Name' },
    #      { :name => :types        , :label => 'Type' },
    #      { :name => :typespecies  , :label => 'Type Species' },
    #      { :name => :type_country , :label => 'Country' },
    #      { :name => :description },
    #      { :name => :recpermission, :label => 'Record Permissions', :edit_type => :collection, :enum_object => Recpermission, :enum_name_column => 'name' }
    #    ]
    #
    #    @update_url = project_taxon_url(params[:project_id], @taxon)
    #
    #    @collections = Collection.find(:all,:conditions=>["taxon_id = #{@taxon.id}"])
    #    @can_edit = false
    #    @can_delete = false
    #    if @taxon.recpermission.name.upcase == Recpermission.delete.upcase || @taxon.user_id == @current_user.id
    #      @can_edit = true
    #      @can_delete = true
    #    elsif @taxon.recpermission.name.upcase == Recpermission.edit.upcase
    #      @can_edit = true
    #      @can_delete = false
    #    end
    #    render(:partial=> "taxon_details", :locals=>{:object => @taxon, :can_edit=> @can_edit, :can_delete=> @can_delete}, :layout => false)
    #  end
  
 
    def delete_selected
      super(passkey.unlock(Taxon))
    end


    def update
      @taxon = (@resource = passkey.unlock(Taxon)).find(params[:id], readonly: false)
      @taxon.transaction do
        params[:taxon][:description]=params[:taxon][:description].gsub("\n","<br/>") if(params[:taxon][:description])
        params[:taxon][:notes]=params[:taxon][:notes].gsub("\n","<br/>") if(params[:taxon][:notes])
        params[:taxon].each do |(k,v)|
          params[:taxon][k] = [*v].first
        end
        @taxon.update_attributes!(params[:taxon])
      end
      respond_to do |format|
        format.json { render json: @taxon }
        format.html { redirect_to(:back)  }
        format.js   { head :ok }
      end
    end
  
  
  
    def destroy_multiple
      ids = Array.new
      moved_to_root = Array.new
      #     err_ids = Array.new
      #        if session[:projects][@current_project.id][:current_selection][:group]
      #          type = session[:projects][@current_project.id][:current_selection][:type]
      #          session[:projects][@current_project.id][:cart][type].each do |item|
      #            if item
      #              ids << item[:id].to_i
      #            end
      #          end
      #        else
      #          ids << session[:projects][@current_project.id][:current_selection][:id].to_i
      #        end
      params[:taxa_ids_to_delete].split(',').each do |taxa_id|
        root_ids = Array.new
        Otu.transaction do
          taxa_child =  passkey.unlock(Taxon).all(:conditions => ["parent_taxon_id = ?",taxa_id])
          taxa_child.each do |taxa_node|
            moved_to_root << {:id => taxa_node.taxon_id , :name => taxa_node.name , :has_children => taxa_node.has_children }
            root_ids << taxa_node.taxon_id
          end
          root_ids.each do |taxa_move_id|
            taxa_move =  passkey.unlock(Taxon).find(taxa_move_id)
            taxa_move.parent_taxon_id = nil
            taxa_move.save!
          end
          passkey.unlock(Taxon).destroy_all(["taxon_id = ? ",taxa_id])
        end
      end
    
      respond_to do |format|
        format.html { redirect_to(:back) }
        format.js { render :json => {:deleted => params[:taxa_ids_to_delete].split(',') , :root_elements => moved_to_root}.to_json() }
        format.xml  { render :xml => ids.to_xml() }
      end
    end
  
    def destroy
      #    successful, failed = Taxon.destroy_if_authorized(params[:id], current_user)
      #    respond_to do |format|
      #      format.js { render :json => Message::Results.new(controller_name, action_name, successful, failed).to_json, :status => :ok }
      #    end
    end
  
    def move_to
      ids = Array.new
      old_parent_ids = Array.new
      #        if session[:projects][@current_project.id][:current_selection][:group]
      #          type = session[:projects][@current_project.id][:current_selection][:type]
      #          session[:projects][@current_project.id][:cart][type].each do |item|
      #            if item
      #              ids << item[:id].to_i
      #            end
      #          end
      #        else
      #          ids << session[:projects][@current_project.id][:current_selection][:id].to_i
      #        end
      new_parent_id = params[:parent_taxon_id]
      params[:taxa_ids_to_move].split(',').each do |taxa_id|
        taxa_rec =  passkey.unlock(Taxon).find(taxa_id, readonly: false)
        old_parent_ids << taxa_rec.parent_taxon_id
        taxa_rec.parent_taxon_id = new_parent_id
        taxa_rec.save!
        #@current_project.taxa.update_all( ["parent_taxon_id = ?",params[:parent_taxon_id].to_i],["id = ?",taxa_id])
      end
    
      respond_to do |format|
        format.js { render :json => params[:taxa_ids_to_move].split(',').to_json() }
        format.xml  { render :xml => ids.to_xml() }
      end
    end

    #      def children
    #        options, find_options = {}, {}
    #        find_options[:include] = options[:include] = word_list(params[:include]).split(',').map{|it| it.to_sym } if params[:include]
    #        options[:only] = word_list(params[:select]).split(',') if params[:select]
    #        @children = current_project.taxa.find(params[:id]).children.find(:all, find_options)
    #        respond_to do |format|
    #          format.js { render :json => @children.to_json(options) }
    #          format.xml  { render :xml => @children.to_xml(options) }
    #        end
    #      end

    def citation_add
      begin
        @taxon.add_citations(params[:citation_ids]) if params.has_key?(:citation_ids)
        head :ok
      rescue => e
        debugger
        head :internal_server_error
      end
      #        if
      #          flash[:notice] = "Added citations successfully."
      #        else
      #          flash[:notice] = "Adding citations failed"
      #        end
      #    respond_to do |format|
      #      format.html
      #      format.js
      #    end
    end

    def citation_insert
      @taxon = current_project.taxa.find(params[:id])
      render :partial  => "/shared/list_citations_taxa" , :collection => @taxon.citations, :locals => {:obj => @taxon, :url_options => { :controller => :taxonomies, :project => @project, :id => @taxon }}
    end
  
    def delete_citation
      @taxon = passkey.unlock(Taxon, to: 'edit').find(params[:id], readonly: false) || fail("You are not permitted to perform this action.")
      @taxon.citations.delete(Library::Citation.find(params[:cit_id]))
      flash[:notice] = "Citation removed successfully."
      respond_to do |format|
        format.js
      end
    end
  
    #get the morphological references of a particular taxon, All scored characters (against this taxa(otu)) and their pics need to be fetched
    def get_morphology_references
      get_references_from_morphology

      respond_to do |format|
        format.js { render 'get_morphology_references', :layout => false }
        format.html
      end
    end
    #i think this should be getting all images from morphology and other places??
    def  get_all_project_images
      get_references_from_morphology
    end

    def get_references_from_morphology
      @codings = Array.new
      @project = current_project
      @taxon = current_project.taxa.find(params[:id])
      matrices = @project.branches.for_morphology_matrices.collect {|matrix_branch| matrix_branch.max_branch_item.item}
      otus = Otu.find_all_with_taxon(@taxon, current_project)
      i=0;
      while i < matrices.size
        @codings[i] = Array.new
        matrix = matrices[i]
        j=0;
        while j < otus.size
          otu = otus[j]
          otu_in_matrix = matrix.otus.find_by_name(otu.name) #Otus in matrix with the same namec
          @codings[i]  << matrix
          if otu_in_matrix
            @codings[i] << matrix.codings.find_all_by_otu_id(otu_in_matrix.id)
            @codings[i].flatten!
          end
          j+=1
        end
        i+=1
      end
    end

    #shows the window for adding taxa to an existing otu/new otu
    def show_add_to_otu
    end

    #adding taxa to an existing otu/new otu
    def add_to_otu
      params[:otu] = {}
      params[:otu][:name] = params[:otu_name]
      #        if session[:projects][@current_project.id][:current_selection][:group]
      #          type = session[:projects][@current_project.id][:current_selection][:type]
      #          session[:projects][@current_project.id][:cart][type].each do |item|
      #            if item
      #              ids << item[:id].to_i
      #            end
      #          end
      #        else
      #          ids << session[:projects][@current_project.id][:current_selection][:id].to_i
      #        end
      ids = params[:taxa_ids_for_otu].split(',')
      if ids
        Otu.transaction do
          @otu = current_project.otus.active.find_by_name(params[:otu][:name]).try(:create_clone) ||
            current_project.otus.create!(params[:otu])
          @otu.taxa << passkey.unlock(Taxon).find(ids)
        end
        #      if @otu.new_record?
        #        @otu.taxa << Taxon.find(ids)
        #        @otu.transaction do
        #          otu_branch = OtuBranch.create!(:created_at => @otu.created_at, :creator => @otu.creator, :project => @otu.project)
        #        end
        #        @otu.save!
        #      else
        #        @new_otu_version = @otu.branch.max_branch_otu.create_new_version(params[:otu])
        #        @new_otu_version.taxa << Taxon.find(ids)
      
        flash[:notice] = 'Successfully added taxon to otu.'
      else
        flash[:notice] = 'Please select at least one taxon.'
      end
    end
  
    def get_dna_references
    end
  
    def species_page
      @taxon = current_project.taxa.find(params[:id])
      respond_to do | format |
        format.html { render :show }
      end
    end

  def search_outlinks
    begin_search
    @results = @taxon.try('get_' + params[:outlink_type] + '_taxa')
    end_search 'search_outlinks'
  end

  def begin_search
    @taxon = passkey.unlock(Taxon, to: 'edit').find(params[:id], readonly: false)
  end

  def end_search partial
    respond_to do |format|
      format.html {render partial, layout: request.xhr? ? false : 'application' }
    end
  end

  def show_jstor_widget
    @taxon = passkey.unlock(Taxon, to: 'view').find(params[:id], readonly: true)
    respond_to { |format| format.html { render :show_jstor_widget, layout: request.xhr? ? false : 'application'} }
  end

    #def treebase_search
    #  uri = 'http://treebase.nescent.org/treebase-web/search/taxonSearch.html?&query=dcterms.title.taxon=%22'
    #  @name_split = params[:name].split(' ')
    #  if @name_split.length > 1
    #    @append_name = ""
    #    @name_split.each do |specifier_name|
    #      @append_name = @append_name + specifier_name + '%20'
    #    end
    #    @append_name = @append_name.chop
    #    @append_name = @append_name.chop
    #    @append_name = @append_name.chop
    #  else
    #    @append_name = params[:name]
    #  end
    #  uri = uri+@append_name+'%22&format=rss1'
    #  @doc = Hpricot(open(uri).string.gsub('.','-'))
    #  render :partial => "shared/treebase_selection"
    #
    #end
    #
    #
    #def ubio_search
    #  key="0e6f4af5959e3c6eb7fa7c0a1dfb578be821c736"
    #  uri = "http://www.ubio.org/webservices/service.php?function=namebank_search&searchName="
    #  @name_split = params[:name].split(' ')
    #  if @name_split.length > 1
    #    @append_name = ""
    #    @name_split.each do |specifier_name|
    #      @append_name = @append_name + specifier_name + '+'
    #    end
    #    @append_name = @append_name.chop
    #  else
    #    @append_name = params[:name]
    #  end
    #  uri = uri+@append_name+"&sci=1&vern=0&keyCode="+key
    #  @doc = Nokogiri::XML(open(uri))
    #  render :partial => "shared/ubio_selection"
    #end

    #def ubio_retrieve_taxon_details
    #  key="0e6f4af5959e3c6eb7fa7c0a1dfb578be821c736"
    #  uri = "http://www.ubio.org/webservices/service.php?function=namebank_object&namebankID="
    #  uri = uri+params[:ubio_id]+"&keyCode="+key
    #  @doc = Nokogiri::XML(open(uri))
    #  render :partial => "shared/ubio_id_desc"
    #end
    #
    #def ncbi_search
    #  esearch_uri = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=Taxonomy&tool=REGNUM&email=ugandharc18@gmail.com&field=SCIN&term="
    #  @name_split = params[:name].split(' ')
    #  if @name_split.length > 1
    #    @append_name = ""
    #    @name_split.each do |specifier_name|
    #      @append_name = @append_name + specifier_name + '+'
    #    end
    #    @append_name = @append_name.chop
    #  else
    #    @append_name = params[:name]
    #  end
    #  uri = esearch_uri+@append_name+'*'
    #  @doc = Nokogiri::XML(open(uri))
    #  @uri_id = ""
    #  @doc.search("//Id").each do |id|
    #    @uri_id = @uri_id + id.inner_html + ","
    #  end
    #  @uri_id = @uri_id.chop
    #  esummary_uri = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=Taxonomy&tool=REGNUM&email=ugandharc18@gmail.com&id="
    #  uri = esummary_uri+@uri_id+"&retmode=xml"
    #  @doc = Nokogiri::XML(open(uri))
    #  render :partial => "shared/ncbi_selection"
    #end
    #
    #def ncbi_retrieve_taxon_details
    #  esummary_uri = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=Taxonomy&tool=REGNUM&email=ugandharc18@gmail.com&id="
    #  uri = esummary_uri+params[:ncbi_id]+"&retmode=xml"
    #  @doc = Nokogiri::XML(open(uri))
    #  render :partial => "shared/ncbi_id_desc"
    #end

    def load_citation_search_widget
      @taxon = passkey.unlock(Taxon).find(params[:id])
      render :partial=>"shared/add_citations_taxon_new", :locals => { :add_citations => @taxon, :ajax_submit => true, :search_url_options =>  {} }
    end

    #  def new_citation_for_taxonomy
    #    @citation = Library::Citation.create_citation params
    #    params[:citation_ids] = [@citation.id]
    #    status = @taxon.add_citations(params[:citation_ids]) ? 'success' : 'failure'
    #
    #    respond_to do |format|
    #      format.html { render text: "<html><body><span id='citation_status'>#{status}</span></body></html>" }
    #    end
    #
    ##      #flash[:notice] = "Added citations successfully."
    ##      render text: "<html><body><span id='citation_status'>success</span></body></html>"
    ##    else
    ##      #flash[:notice] = "Adding citations failed"
    ##      render text: "<html><body><span id='citation_status'>failed</span></body></html>"
    ##    end
    #  end

    def citation_type_selection
      render :partial => "shared/new_citation_taxa_window" ,:locals => {:controller => "Taxonomy"}
    end

  def stream_csv
    respond_to do |format|
      format.csv do
        headers["X-Accel-Buffering"] = "no"
        headers["Cache-Control"] = "no-cache"
        headers["Content-Type"] = "text/csv; charset=utf-8"
        headers["Content-Disposition"] = %(attachment; filename="tolkin_report.csv")
        headers["Last-Modified"] = Time.zone.now.ctime.to_s

        self.response_body = CsvExporter::Export.stream_csv(@current_project.taxa.find_each.lazy.map{ |t| t }, params[:taxon].values)
      end
    end
  end

    def export_csv
      @taxa_export = @current_project.taxa.find(:all)
      csv = CsvExporter::Export.export_to_csv(@taxa_export, params[:taxon].values)
      send_data(csv,
        :type => 'text/csv; charset=utf-8; header=present',
        :disposition => "attachment",
        :filename => "tolkin_report.csv")
    end
   
    def display_taxa_column_names
      @taxa_col = Taxon.column_names.reject{|col_name|col_name.include?('_id') || col_name.include?('rtid') || col_name.include?('vtid') || %w(created_at updated_at has_children deleted_at).include?(col_name) }

      @table_col = @taxa_col
      render :partial => "shared/list_of_table_columnnames" , :locals => {:controller_name => "taxa"}
    end

    #   def citaion_type_selection
    #    render :partial => "shared/new_window" ,:locals => {:controller => "Taxonomy"}
    #  end

    private

    def perm_selections_match? perm_vals_hash, perm_array, all_roles
      all_roles.all? do |role|
        if(role_perms = perm_vals_hash[role.rtid])
          if((permission = perm_array.shift) && permission.role_rtid == role.rtid) # if perm found
            if permission.visible == !!role_perms['visible'] &&
                permission.editable == !!role_perms['editable'] &&
                permission.deletable == !!role_perms['deletable'] &&
                permission.permissible == !!role_perms['permissible']
              true
            else
              false
            end
          else
            false
          end
        else # all perms should be set to false for this role
          if((permission = perm_array.shift) && permission.role_rtid == role.rtid) # if perm found
            if permission.visible || permission.editable || permission.deletable || permission.permissible # if perm has any permitted actions
              false
            else # no permitted actions
              true
            end
          else # no perm found
            true
          end
        end
      end
    end

    #  def new_taxon
    #    params[:taxon][:project_id] = @current_project.id
    #    params[:taxon][:updater_id] = @current_user.id
    #    params[:taxon][:creator_id] = @current_user.id
    #    @taxon = Taxon.new(params[:taxon])
    #    @taxon.save!
    #    respond_to do |format|
    #      format.html { redirect_to(:back)  }
    #    end
    #
    #  end
  
    #  def assign_other_information
    #    @taxon.project = @project
    #    @taxon.citations = Library::Citation.find(params[:citation_ids]) if params[:citation_ids]
    #    #@taxon.last_updated_by= @current_user
    #    #@taxon.user = @current_user
    #    @taxon.updater_id =  @current_user.id
    #    @taxon.creator_id =  @current_user.id
    #  end
  
    #  def find_project
    #    @project = Project.find(params[:project_id])
    #    raise "Could Not Find Project with id #{params[:project_id]}" if @project.nil?
    #  end
  
    def handle_permission_denied(method)
      case method
      when "update"
        redirect = "show"
        permission = "edit"
      else
        redirect = "index"
      end
      session[:permission_denied] = false
      render :update do |page|
        page.replace_html('notice',flash[:notice].to_s)
      end
    end
    def find_taxon
      @taxon = passkey.unlock(Taxon).find(params[:id], readonly: false)
      raise "Could Not Find Taxon with id #{params[:id]}" if @taxon.nil?
    end
  end
