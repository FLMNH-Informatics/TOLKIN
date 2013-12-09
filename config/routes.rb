Tolkin::Application.routes.draw do |map|
  # netzke

  #SprocketsApplication.routes(map)

  #TODO make the post verbs for delete related actions to :delete verb, this would involve changed the views too so need to do this carefully but i think is recommeneded.

  #TODO bring me back SprocketsApplication.routes(map)

  #  map.getstates '/projects/:project_id/matrices/:id/get_states/:otu_id/:chr_id', :controller => 'Morphology::Matrices', :action => 'get_states'
  #
  #  map.modifymatrix '/projects/:project_id/matrices/:id/modify_matrix', :controller => 'Morphology::Matrices', :action => 'modify_matrix'
  #  map.change_position '/projects/:project_id/matrices/:id/change_position', :controller => 'Morphology::Matrices', :action => 'change_position', :method => :put
  #  map.update_state_codings '/projects/:project_id/matrices/:id/update_state_codings/:otu_id/:chr_id', :controller => 'Morphology::Matrices', :action => 'update_state_codings'
  #  map.show_matrix '/projects/:project_id/show_matrix/:object_history_id.:branch_number.:branch_position', :controller => 'Morphology::Matrices', :action => 'show'
  #  map.edit_matrix '/projects/:project_id/edit_matrix/:object_history_id.:branch_number.:branch_position', :controller => 'Morphology::Matrices', :action => 'edit'
  #  map.get_species_page '/projects/:project_id/taxa/:id/get_species_page', :controller => 'Taxa', :action => 'get_species_page'
  #  #map.ubio_search '/projects/:project_id/taxonomies/ubio_search', :controller => 'Taxonomies', :action => 'ubio_search'

  root to: "projects#index"

  #match "/" => "projects#index"
  match '/signup' => 'users#new', as: :signup
  match '/login' => 'sessions#new', as: :login
  match '/logout' => 'sessions#destroy', as: :logout
  #  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  #  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate'
  #  #map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  #  #map.reset_password '/reset_password/:id', :controller => 'passwords', :action => 'edit'
  #map.change_password '/change_password', :controller => 'accounts', :action => 'edit'
  match '/change_password' => 'accounts#edit', as: :change_password
  match '/change_password/:user_id' => 'accounts#edit', as: :change_password_for_user
  #
  match '/templates/*template_paths' => 'templates#show', method: :get, as: :templates
  #  map.templates '/templates/*template_paths', :controller => 'templates', :action => 'show', :method => :get

  match '/projects/:project_id/image_album', method: :index, :controller => 'image_albums', :action => 'index'
  match '/projects/:project_id/:controller/display_column_names', method: :get, :action => 'display_column_names'

  match '/help', :controller => 'application', :action => 'get_help_file' , :method => :get
  match '/projects/:project_id/license_info/:id', :controller => :projects, :action => :license_info, :method => :get
  resource :sprockets

  resource :admin, :controller => 'admin'   do
    get :list_users, on: :collection
  end
  namespace :admin do
    resources :projects
    resources :users do
      member do
        get :roles
        post :assign
        post :unassign
      end
    end
  end

  resources :namestatuses

  resources :users do
    put :enable, on: :member
    get :add_user_to_project, on: :collection
    #get :add_user_to_project, on: :member
    get :search, on: :collection
    resource :account
    resource :granted_roles
  end

  resources :tags do
    get :auto_complete_for_tag_name, on: :collection
    resources :taggings
  end

  resources :statuses
  resources :length_units
  resource :session
  resource :password

  namespace :ncbi do
    resources :bioentries
  end

  namespace :molecular do
    namespace :resources do
      namespace :ncbi do
        resources :e_utils do
          collection do
            get :esearch
            get :esearch_esummary
            get :check_identifier
          end
        end
      end
    end
  end

  resources :projects do
    post :make_all_public,        on: :member
    post :make_all_private,       on: :member
    post :make_public,            on: :member
    post :make_private,           on: :member
    get :get_public_status,       on: :member
    get :get_public_model_status, on: :member
    resource :admin, :controller => 'admin'   do
      get :list_users, on: :collection
    end

    resources :users
    resources :roles
    resources :permission_sets
    resources :nexus_datasets

    namespace :chromosome do
      resources :dyes do
        resources :dye_compositions
        put :destroy_all, on: :collection
        get :ajax_new, on: :member
      end

      resources :dye_compositions do
        put :destroy_all, on: :collection
      end

      resources :probes do
        member do
          get :tooltip_show
          get :z_files
        end
        collection do
          get :show_new_upload
          post :new_upload
          post :bulk_upload
          get :view_map
          delete :delete_selected
        end
        resources :z_files

      end

      resources :z_files do
        member do
          put :attach_image
          delete :remove_image
          put :remove_hybridization
          put :create_hybridization
          get :download_z_file
          get :show_add_probe
        end
        collection do
          get :download_z_files
          put :destroy_all
          delete :delete_selected
        end
      end

    end
    resource :admin, :controller => 'admin'

    # get :collections, on: :member
    resources :statuses
    resources :people

    resources :images do
      post :swfupload, on: :collection
      resources :joins, controller: 'image_joins'
    end

    resources :sequences, controller: 'ncbi/seqs'

    namespace :morphology do
      resources :characters do
        collection do
          get :auto_complete_for_chr_state_name
          delete :delete_selected
          get :add_to_matrix
          put :add_to_matrix_update
          get :add_to_group
          put :add_to_group_update
          get :auto_complete_for_character_name
        end
        member do
          post :create_state
          post :delete_state
          post :send_email
          post :citation_custom_search
          post :citation_add
          put  :attach_image
          post :remove_image
          post :remove_state
          post :remove_citation
          get :show_add_citation
          post :citation_add

        end
        resources :chr_states do
          member do
            post :citation_add
            get :show_add_citation
            get :show_add_image
            get  :add_chr_state_image
            post :remove_citation
            put  :attach_image
            post :attach_image
            post :remove_image
          end
        end
      end

      resources :chr_states do
        member do
          post :delete_citation
          post :remove_citation
          post :citation_add
          post :attach_image
          post :remove_image
        end
      end

      resources :chr_groups do
        collection do
          get :auto_complete_for_chr_group_name
          get :auto_complete_for_character_name
          get :add_to_matrix
          put :add_to_matrix_update
          delete :delete_selected
          post :remove_selected
        end
        member do
          post :add_character
          post :remove_character
          get :show_add_character
          post :change_position
        end
      end

      resources :matrices do
        collection do
          get :show_designate_submatrix_window
          post :designate_submatrix
          post :process_index_modify_matrix
          delete :delete_selected
          post :add_citations_state_codings
          get :auto_complete_for_otu_name
          get :auto_complete_for_branch_name
          get :auto_complete_for_character_name
          get :select_for_branch_version
          get :show_merge_window
          post :merge
          get :show_merge_matrices
          get :show_designate_submatrix
        end
        member do
          post :update_info
          get :show_revert_to_version
          post :revert_to_version
          post :revert_change
          #get :revert_change
          get :get_tooltips
          get :add_character
          post :update_character
          get :add_otu
          post :update_otu
          put :remove_otu
          put :remove_character
          post :merge_with_parent
          get :show_submatrix
          get :add_submatrix
          get :do_export
          get :export_matrix
          get :modify_matrix
          post :update_color_picker
          get :show_commit_changes_options
          post :commit_changes
          post :redirect_to_version
          get :show_copy_matrix_options_window
          put :copy_matrix
          delete :destroy_branch
          get :show_matrix_details
          get :show_matrix_history
          get :new_submatrix
          put :create_submatrix
          post :revert_all_changes
          post :change_position
          get :show_add_character
          get :show_add_otu
          get :show_view_by_date
          get :get_times_for_date
          get :view_by_date
          get :show_next_version
          post :create_next_version
          get :show_copy_matrix
          get :load_row
          post :copy_matrix
        end
        resources :cells, controller: 'matrix/cells' do
          member do
            get  :show_cell_info
            get  :show_add_citation
            post :citation_add
            post :remove_image
            post  :remove_citation
          end
        end
        resources :state_codings, controller: 'matrix/state_codings'
        resources :matrices_otu_groups, controller: 'matrix/matrices_otu_groups'
        resources :characters do
          collection do
            get :auto_complete_for_chr_state_name
            delete :delete_selected
            get :add_to_matrix
            put :add_to_matrix_update
            get :add_to_group
            put :add_to_group_update
            get :auto_complete_for_character_name
          end
          member do
            put :attach_image
            post :create_state
            post :delete_state
            post :send_email
            post :citation_custom_search
            post :citation_add
            post :remove_citation
            post :remove_image
            get :show_add_citation
            post :citation_add
          end
          resources :chr_states do
            member do
              post :citation_add
              get :add_chr_state_image
              post :remove_citation
              get :show_add_citation
              get :show_add_image
              post :attach_image
              post :remove_image
            end
          end
        end
      end
    end

    resources :changesets, controller: 'matrix/changesets' do
      resources :changes, controller: 'matrices/changesets/changes' do
        post :revert_all, on: :collection
        post :revert, on: :member
      end
    end

    resources :workflows

    resources :otu_groups do
      collection do
        get :auto_complete_for_otu_group_name
        get :auto_complete_for_otu_name
        delete :delete_selected
        get :add_to_matrix
        put :add_to_matrix_update
        post :remove_selected
        get :add_otu_to_group
      end
      member do
        post :remove_otu
        post :change_position
        get :show_add_otu
        post :add_otu
      end
    end

    resources :otus do
      collection do
        get :show_new_upload
        post :new_upload
        post :bulk_upload
        get :view_map
        post :destroy_all
        get :auto_complete_for_otu_name
        get :auto_complete_for_taxon_name
        get :add_to_otu_group_wizard
        delete :delete_selected
        post :add_to_group
        get :add_to_matrix
        put :add_to_matrix_update
      end
      member do
        post :citation_add
        get :add_image_window
        get :show_add_taxon
        post :add_taxon
        post :remove_taxon
      end
    end

    resources :custom_mappings

    resources :taxa do
      collection do
        get :show_new_upload
        post :new_upload
        post :bulk_upload
        get :view_map
        get :citation_insert
        get :display_taxa_column_names
        get :ubio_retrieve_taxon_details
        get :ubio_search
        get :ncbi_search
        get :ncbi_retrieve_taxon_details
        get :index
        get :tree_view
        post :set_permissions
        get :set_permissions_view
        get :show_add_to_otu
        post :add_to_otu
        get :auto_complete_for_otu_name
        get :auto_complete_for_taxon_name
        post :destroy_multiple
        post :citation_add
        delete :delete_selected
        get :list
        get :export_csv
      end
      member do
        get :load_citation_search_widget
        post :citation_type_selections
        post :new_citation_for_taxonomy
        get :species_page
        get :children
        get :get_all_project_images
        get :get_morphology_references
        get :taxon_details
        get :fetch_children
        put :update_taxon
        put :move_to
        post :citation_add
        delete :delete_citation
        get :return_collection
        get :synonyms
        post :add_protologue
        get :get_protologue
        delete :delete_protologue
        get :search_treebase
        get :search_outlinks
      end
      resources :images, controller: 'taxa/images'
      resources :collections
      resources :sequences, :controller => 'insd/seqs'
    end

    resources :collections do

      collection do
        resources :bulk_uploads, :controller => 'collections/bulk_uploads' do
          collection do
            get :template_column_mapping
            get :download_template
            get :new_bulk_upload
            post :after_column_mapping
            get :column_module_type
            get :get_custom_mapping
          end
          get :download_bulk_upload_templates
        end
        get :show_new_upload
        post :new_upload
        post :bulk_upload
        get :view_map
        delete :delete_selected
        put :create_copy
        get :auto_complete_for_collection_collection_number
        get :display_collection_column_names
        get :export_csv
      end

      member do
        put :update_collection
        put :update_others
      end
      resources :images, controller: 'collections/images'
      resources :annotations, controller: 'collections/annotations'
    end

    namespace :library do
      resources :citations do
        collection do
          get :show_new_upload
          post :new_upload
          post :bulk_upload
          get :view_map
          delete :delete_selected
          get :new_two
          get :search
          get :bulk_upload
          post :bulk_create
          get :getfile
          get :publications_search
          get :contributorships_author_search
          get :add_new_authors
          get :citations_search
          get :citation_custom_search
          post :citation_add
          get :check_author
        end
        member do
          get :check_author
        end
      end
      resources :publications do
        delete :delete_selected, on: :collection
      end
      resources :publishers do
        collection do
          get :publishers_search
          delete :delete_selected
        end
      end

      resources :authors do
        collection do
          get :index
        end
      end
    end

    namespace :molecular do
      resources :markers, :controller => 'markers' do
        collection do
          get :index
          post :merge
          delete :delete_selected
        end
        member do
          put :update
          post :update
          put :destroy
          get :display_seqs
          get :display_matrices
          get :display_primers
        end
      end

      resources :import_fasta_seqs, :controller => 'import_fasta_seqs'
      resources :fasta_filename,    :controller => 'fasta_filenames'

      resources :sequences, :controller => 'insd/seqs' do
        resources :probes, :controller => 'chromosome/probes'
        collection do
          delete  :delete_selected
          post  :import_from_genbank
          post  :new_from_genbank
          post  :create_marker
          get   :auto_complete_for_collection_collection_number
          get   :show_add_genbank_seqs
          get   :show_upload_seqs
          post  :import_seqs
          get   :new_sequence_marker_select
          put   :post_genbank_data_receive_file
          put   :export_to_genbank
          put   :destroy_all
          get   :show_genbank_form
          get   :browse_fasta_file
          put   :import_fasta_file
          get   :import
          get   :export
          post  :export_from_cells
          post  :export_from_seqs
          get   :get_fasta
          post   :seq_ids_from_markers_and_otus
          get   :do_export_ids
          put   :save_dna_seq_info
          post  :align
          get   :search_nucleotide
          post  :show_create_alignment
          get  :show_create_alignment
          post   :render_alignment_seqs
          post  :create_alignment
          get   :show_from_fasta
        end
        member do
          get  :import
          post :remove_probe_from_insd_seq
          post :assign_probe_to_insd_seq
          post :remove_marker
        end
      end



      resources :bioentries do
        collection do
          delete :delete_selected
          get :auto_complete_for_collection_collection_number
          put :export_to_genbank
          put :import_fasta_file
          get :show_genbank_form
          put :save_dna_seq_info
        end
      end
      resources :dna_samples do
        get :show_no_edit, on: :member
        collection do
          post :destroy_all
          delete :delete_selected
          get :auto_complete_for_collection_collection_number
          get :display_dna_samples_column_names
          get :show_new_upload
          get :view_map
          post :new_upload
          post :bulk_upload
        end
        member do
          get :display_dna_samples_column_names
        end
      end

      resources :primers do
        collection do
          get  :auto_complete_for_marker_name
          post :destroy_all
          delete :delete_selected
        end
        member do
          post :update_primer
        end
      end

      resources :alignments do
        collection do
          get  :import_pre
          post :import
          delete :delete_selected
        end
        member do
          put  :remove_sequence
          put  :update_alignment_info
          get  :export_fasta
          get  :export_clustal
          get  :export
          get  :retrieve_alignment_text
          post :create_alignment_text
        end
        resources :alignment_outputs, :controller => 'alignment/alignment_outputs' do
          member do
            post :new
          end
        end
      end

      resources :matrices, controller: :matrices do
        collection do
          delete :delete_selected
        end
        member do
          get  :show_autofill_matrix
          post :autofill_matrix
          get  :show_add_marker
          get  :show_add_otu
          post :add_otu
          post :add_marker
          post :update_otu
          post :update_marker
          put  :remove_marker
          put  :remove_otu
          get  :modify_matrix
          get  :bulk_sequence_exporter
          get  :show_view_by_date
          get  :view_by_date
          post :change_position
          post :copy_matrix
          get  :copy_matrix
          get  :get_times_for_date
          get  :show_copy_matrix
          post :update_info
          post :create_next_version
          get :show_next_version
          get :show_create_next_version
          get :load_row
        end

        resources :submatrices, controller: 'matrix/submatrices' do
          member do
            post :change_position
          end
        end

        resources :cells, :controller => 'matrix/cells' do
          collection do
            post :new_cell
            get  :new_cell
          end
          member do
            post  :add_sequence
            get   :show_search_genbank
            get   :search_genbank
            post  :update_cell_data
            put   :update_cell_data
            get   :show_cell
            get   :show_cell_info
          end
        end

        resources :sequences, :controller => 'matrix/cell/sequences'

        resources :markers do
          get :auto_complete_for_marker_name, on: :collection
        end
      end

#      resources :markers
      resources :purification_methods

      resources :marked_records do
        collection do
          get :list_columns
          post :export_records
        end
      end

      namespace :plastome do
        resources :tables do
          delete :delete_selected, on: :collection
          member do
            post :add_sequence
            get :show_search_genbank
            get :search_genbank
          end
          resources :sequences, controller: 'matrix/cell/sequences'
        end
      end

      resources :alignments do
        collection do
          get :import_pre
          post :import
        end
      end


    end

    resource :image_albums, :controller => 'image_albums' do
      collection do
        get :index
        get :search
        get :get_image
        put :update_image
      end
     # member do
     #   get :index
     # end
      #, :member => {:search => :get}
    end

  end

  resources :issues do
    member do
      post :create
    end
  end

  resources :filters, only: :index

  #      molecular.resources :alignments, :collection => { :import_pre => :get, :import => :post }
  #
  #      molecular.resources :matrices, :controller => :matrices,
  #        :collection => { :auto_complete_for_marker_name => :get },
  #        :member => { :change_position => :post, :design => :get, :show_add_otu => :get, :add_otu => :post, :revert_change => :post, :show_add_marker => :get,
  #        :add_marker => :post, :show_cell_details => :get, :show_commit_changes_options => :get, :commit_changes => :post, :remove_marker => :put, :remove_otu => :put } do |matrices|
  #        matrices.resources :markers, :collection => { :auto_complete_for_marker_name => :get }
  #        matrices.resources :matrices_otu_groups, :controller => 'matrix/matrices_otu_groups'
  #        matrices.resources :cells, :controller => 'matrix/cells',
  #          :member => { :add_sequence => :post, :show_search_genbank => :get, :search_genbank => :get } do |cells|
  #          cells.resources :sequences, :controller => 'matrix/cell/sequences'
  #        end
  #      end
  #      molecular.resources :markers, :collection => { :auto_complete_for_marker_name => :get}
  #    end
  #    project.resources :marked_records, :collection => {:list_columns => :get, :export_records => :post}
  #    project.resources :nexus_datasets
  #  end
  #
  #  map.search_filter '/project/:project_id/search_filter',:controller => 'search', :action => 'search_filter'
  #  map.past_searches 'project/:project_id/search/past_searches',:controller => 'search', :action => 'past_searches'
  #
  #  #map.custom_search '/project/:project_id/custom_search',:controller => 'search', :action => 'custom_search', :conditions => { :method => :post }
  #  map.search '/project/:project_id/search', :controller => 'search', :action => 'index'
  #  map.auxsearch '/project/:project_id/search/search', :controller => 'search', :action => 'search'
  #
  #  
  #
  #  map.resources :filters ,  :only => [ :index]
  #
  #  map.connect ':controller/:action/:id'
  #  map.connect ':controller/:action/:id.:format'
end
