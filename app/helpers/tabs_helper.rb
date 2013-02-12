module TabsHelper
  def tabs
    # molecular section link removed until section in better shape
    #display_tabs = [ :projects, :taxa, :chr_matrices, :collections, :citations, :tags, :search ]

    #items removed from tab for now  :tags, :workflows
    display_tabs = [ :projects, :taxa, :chr_matrices, :molecular, :chromosome, :collections, :citations, :image_albums, :help ] #, :search ]

    #disabled Admin section for now
    display_tabs << :admin if is_admin? #if is_manager?
    if is_admin?
      @@nav_menu[:primary][:admin][:subnav] = [ :user_controls, :roles, :permission_sets, :issues, :project_controls]
    else
      @@nav_menu[:primary][:admin][:subnav] = [ :user_controls, :project_controls]  if is_manager?
      # @@nav_menu[:primary][:admin][:subnav] = [ :user_controls, :project_controls]
    end
    if params[:public_user]
      @@nav_menu[:primary][:taxa][:subnav] = [ :taxa_catalog, :taxa_list ]
      @@nav_menu[:primary][:chromosome][:subnav] = [ :probes, :z_files ]
    else
      @@nav_menu[:primary][:taxa][:subnav] = [ :taxa_catalog, :taxa, :otus, :otu_groups ]
      @@nav_menu[:primary][:chromosome][:subnav] = [ :probes, :z_files ]
    end
    display_tabs
  end

  # new map for determining current tab - should speed things up if the current_tab?
  # method doesn't require traversing the whole tab map just to see if a tab is active or not
  @@current_tab_by_controller_action = {

    :taxa                      => { :default => { }, :index => { :secondary => :taxa_catalog }, :list => {:secondary => :taxa_list} },
    :granted_roles             => { :default => { :primary => :admin, :secondary => :user_controls } },
    :"admin/users"             => { :default => { }, :index => { :primary => :admin, :secondary => :user_controls }, :new => {:primary => :admin, :secondary => :user_controls} },
    :help                      => { :default => { }, :index => {  } },
    :"morphology/characters"   => { :default => { :primary => :chr_matrices, :secondary => :characters } },
    :"morphology/chr_groups"   => { :default => { :primary => :chr_matrices, :secondary => :chr_groups } },
    :"morphology/matrices"     => { :default => { :primary => :chr_matrices, :secondary => :chr_matrices } },
    :"molecular/dna_samples"   => { :default => { :primary => :molecular, :secondary => :dna_samples } },
    :"molecular/insd/seqs"     => { :default => { :primary => :molecular, :secondary => :seqs } },
    :"molecular/primers"       => { :default => { :primary => :molecular, :secondary => :primers } },
    :"molecular/alignments"    => { :default => { :primary => :molecular, :secondary => :alignments } },
    :"molecular/matrices"      => { :default => { :primary => :molecular, :secondary => :mol_matrices } },
    :"molecular/markers"        => { :default => { :primary => :molecular, :secondary => :markers}},
    :"chromosome/probes"        => { :default => { :primary => :chromosome, :secondary => :probes} },
    :"chromosome/sequence_contigs"  => { :default => { :primary => :chromosome, :secondary => :sequence_contigs} },
    :"chromosome/z_files"      => { :default => { :primary => :chromosome, :secondary => :z_files} },
    :"collections/bulk_uploads"      => { :default => { :primary => :collections, :secondary => :bulk_uploads} },
    :"library/citations"       => { :default => { :primary => :citations, :secondary => :citations } },
    :"library/publications"    => { :default => { :primary => :citations, :secondary => :publications } },
    :"library/publishers"      => { :default => { :primary => :citations, :secondary => :publishers } },
    :"library/people"          => { :default => { :primary => :citations, :secondary => :people } },
    :roles                     => { :default => { :primary => :admin,     :secondary => :roles } },
    #:permission_sets           => { :default => { :primary => :admin,     :secondary => :permission_sets } },
    :"admin/projects"          => { :default => { :primary => :admin,     :secondary => :project_controls } }
  }

  # map for holding display and linking behavior of tabs
  @@nav_menu = {
    :primary => {
        :projects   => { :text => "Home",
                :active_when => { :no_login => true },
                :link => "projects_path" },
      :taxa  => { :text => "Taxonomy",
        :active_when => { :no_project => false, :no_login => true },
        :link => "project_taxa_path(session[:project_id] || '')" },

      :chr_matrices => { :text => "Morphology",
        :active_when => { :no_project => false, :no_login => false },
        :subnav => [ :chr_matrices, :characters, :chr_groups ],
        :link => "project_morphology_matrices_path(session[:project_id] || '')" },

      :molecular  => { :text => "Molecular",
        :active_when => { :no_project => false, :no_login => false },
        :subnav => [ :mol_matrices, :dna_samples, :seqs, :alignments, :primers, :markers ],
        :link => "project_molecular_matrices_path(session[:project_id] || '')" },

      :chromosome => { :text => "Chromosome",
        :active_when => { :no_project => false, :no_login => true },
        :subnav => [ :sequence_contigs,:probes, :z_files ],
        :link => "project_chromosome_probes_path(session[:project_id] || '')" },

      :citations  => { :text => "Library",
        :active_when => { :no_project => false, :no_login => false },
        :subnav => [ :citations ],
        :link => "project_library_citations_path(session[:project_id] || '')" },

      :workflows => { :text => "Workflows",
        :active_when => { :no_project => false, :no_login => false },
        :link => "project_workflows_path(session[:project_id] || '')"},

      :collections => { :text => "Collections",
        :active_when => { :no_project => false, :no_login => false },
        :subnav => [:coll_catalog, :bulk_uploads ],
        :link => "project_collections_path(session[:project_id] || '')" },

      :image_albums => { :text => "Images",
        :active_when => { :no_project => false, :no_login => false },
        :link => "project_image_albums_path(session[:project_id] || '')" },

      :tags       => { :text => "Tags",
        :active_when => { :no_login => false },
        :link => "tags_path" },

       :admin      => { :text => "Admin",
        :active_when => { :no_project => true, :no_login => false},
        :subnav => [ :user_controls, :roles, :permission_sets ],
        :link => "admin_users_path" },

      :help => { :text => "Help", :active_when => { :no_project => false, :no_login => false}, :link => "help_path" },
#      :search     => { :text => "Search",
#        :active_when => { :no_project => false, :no_login => false },
#        :link => "search_path(session[:project_id] || '')" },

      :home   => { :text => "Home",
        :active_when => { :no_login => true },
        :link => "project_path(current_project.id)" },
    },
    #TODO rather than listing controller these secondaries should just have path attributes
    :secondary => {
      :taxa          => { :title => "Taxon Tree View",                            :path => "tree_view_project_taxa_path(session[:project_id] || '')" },
      :taxa_list     => { :title => "Taxon List",                                 :path => "list_project_taxa_path(session[:project_id] || '')"},
      :taxa_catalog  => { :title => "Taxon Catalog",    :parent => :taxa,         :path => "project_taxa_path(session[:project_id] || '')" },
      :otus          => { :title => "OTUs",             :parent => :taxa,         :path => "project_otus_path(session[:project_id] || '')" },
      :otu_groups    => { :title => "OTU Groups",       :parent => :taxa,         :path => "project_otu_groups_path(session[:project_id] || '')" },
      :bulk_uploads  => { :title => "Bulk Uploads",     :parent => :collections,  :path => "project_bulk_uploads_path(session[:project_id] || '')", :controller => "collections/bulk_uploads" },
      :coll_catalog  => { :title => "Collection Catalog", :parent => :collections, :path => "project_collections_path(session[:project_id] || '')", :controller => "collections"},
      :chr_matrices  => { :title => "Matrices",                                   :path => "project_morphology_matrices_path(session[:project_id] || '')", :controller => "morphology/matrices" },
      :chr_groups    => { :title => "Character Groups", :parent => :chr_matrices, :path => "project_morphology_chr_groups_path(session[:project_id] || '')" },
      :characters    => { :title => "Characters", :parent => :chr_matrices, :path => "project_morphology_characters_path(session[:project_id] || '')" },
      :dna_samples   => { :title => "Raw DNA", :path => "project_molecular_dna_samples_path(session[:project_id] || '')" },
      :seqs          => { :title => "Sequences", :path => "project_molecular_sequences_path(session[:project_id] || '')" },
      :primers       => { :title => "Primers", :path => "project_molecular_primers_path(session[:project_id] || '')" },
      :markers       => { :title => "Markers", :path => "project_molecular_markers_path(session[:project_id] || '')" },
      :alignments    => { :title => "Alignments", :path => "project_molecular_alignments_path(session[:project_id] || '')" },
      :mol_matrices  => { :title => "Matrices", :path => "project_molecular_matrices_path(session[:project_id] || '')", :controller => "molecular/matrices" },
      :citations     => { :title => "Citations", :path => "project_library_citations_path(session[:project_id] || '')" },
      :publications  => { :title => "Publications", :parent => :citations, :path => "project_library_publications_path(session[:project_id] || '')" },
      :publishers    => { :title => "Publishers", :parent => :citations, :path => "project_library_publishers_path(session[:project_id] || '')" },
      :people        => { :title => "People", :parent => :citations, :path => "project_people_path(session[:project_id] || '')" },
      :user_controls => { :title => "User Controls", :parent => :admin, :path => "admin_users_path" },
      :sequence_contigs => { :title => "Sequences", :parent => :chromosome, :path => "project_molecular_sequences_path(session[:project_id] || '')"  },
      :probes          => { :title => "Probes", :parent => :chromosome, :path => "project_chromosome_probes_path(session[:project_id] || '')" },
      :z_files       => { :title => "ZVI Files", :parent=> :chromosome, :path => "project_chromosome_z_files_path(session[:project_id] || '')" },
      :roles         => { :title => "Roles", :parent => :admin, :path => "project_roles_path(current_project.id)" },
      :permission_sets => { :title => "Permission Sets", :parent => :admin, :path => "project_permission_sets_path(current_project.id)" },
      :issues        => { :title => "Feedback", :parent=> :admin, :path => "issues_path" },
      :project_controls => { :title => "Projects", :parent=> :admin, :path => "admin_projects_path"}

    }
  }

  def generate_tabs
    controller_name = self.controller.controller_name
    result_str = "<ul id='navbar'>"
    @current_tab = get_current_tab
    tabs.each do |tab|
      dropdown=""
      dropdown << '<ul>'
      if(@@nav_menu[:primary][tab][:subnav]!=nil && active_tab?(tab))
        @@nav_menu[:primary][tab][:subnav].each do |subtab|

            dropdown <<	"<li>#{link_to "#{@@nav_menu[:secondary][subtab][:title]}", eval(@@nav_menu[:secondary][subtab][:path]) }</li>"

        end
      end       
      dropdown << '</ul>'

      # send project_id as param to next controller only if it is a project specific controller
      project_id = nil
      project_id = session[:project_id] unless tab.to_s == 'projects' || tab.to_s == 'tag' || tab.to_s == 'admin'

      # determine tab class for css display purposes
      tab_class = tab_class?(tab)

      # display tab
      result_str << "<li class='#{tab_class}'>"
      result_str << (
        (tab_class == 'top_tab inactive') ?
          "<span>#{@@nav_menu[:primary][tab][:text]}</span>" :
          "<a href='#{eval(@@nav_menu[:primary][tab][:link])}'>#{@@nav_menu[:primary][tab][:text]}</a>"
      )
      #result_str << temp_str

      result_str << dropdown
      result_str << "</li>"
    end

    result_str << "</ul>"
  end

  def generate_subtabs

    # show subnavigation if current tab is selected
    @current_subtab = get_current_subtab

    # send project_id as param to next controller only if it is a project specific controller
    project_id = nil
    project_id = session[:project_id] unless @current_tab.to_s == 'projects' || @current_tab.to_s == 'tag' || @current_tab.to_s == 'admin'

    if (@current_tab && @@nav_menu[:primary][@current_tab][:subnav])
      result_str = "<ul id='secondary'>"
      @@nav_menu[:primary][@current_tab][:subnav].each {|subtab|
        # is currently selected subtab if controller name equals subtab name or the controller name set for current subtab
        if @current_subtab == subtab
          result_str << ("<li class='top_subtab current'><a href='#{eval(@@nav_menu[:secondary][subtab][:path])}'>#{@@nav_menu[:secondary][subtab][:title]}</a></li>")
          # inactive subtab if link location not given
        elsif @@nav_menu[:secondary][subtab][:path] == false
          result_str << "<li class='top_subtab inactive'><span>#{@@nav_menu[:secondary][subtab][:title]}</span></li>"
          # active linking subtab otherwise
        else
          result_str << "<li class='top_subtab active'><a href='#{eval(@@nav_menu[:secondary][subtab][:path])}'><span>#{@@nav_menu[:secondary][subtab][:title]}</span></a></li>"
        end
      }
      result_str << "</ul>"
    end
  end

  private

  def get_current_tab
    # removes slash from front of controller name
    controller_name = controller.controller_path.to_sym
    action_name = controller.action_name.to_sym
    current_tab = controller_name if @@nav_menu[:primary][controller_name]
    current_tab ||= @@nav_menu[:secondary][controller_name][:parent] if @@nav_menu[:secondary][controller_name]

    if @@current_tab_by_controller_action[controller_name]
      current_tab ||= @@current_tab_by_controller_action[controller_name][action_name][:primary] if @@current_tab_by_controller_action[controller_name][action_name]
      current_tab ||= @@current_tab_by_controller_action[controller_name][:default][:primary]
    end

    current_tab


  end

  def get_current_subtab
    # removes slash from front of controller name
    controller_name = controller.controller_path.to_sym
    action_name = controller.action_name.to_sym
    current_subtab = controller_name if @@nav_menu[:secondary][controller_name]
    if @@current_tab_by_controller_action[controller_name]
      current_subtab = @@current_tab_by_controller_action[controller_name][action_name][:secondary] if @@current_tab_by_controller_action[controller_name][action_name]
      current_subtab ||= @@current_tab_by_controller_action[controller_name][:default][:secondary]
    end
    current_subtab
  end

  def active_tab?(tab)
    # if there are no show_as_active conditions declared, make active all the time
    return true if @@nav_menu[:primary][tab][:active_when].nil?
    # don't display if one of the no_display conditions is met
    return false if (@@nav_menu[:primary][tab][:active_when][:no_login] == false && (!current_user || (current_user == User.public_user))) ||
      (@@nav_menu[:primary][tab][:active_when][:no_project] == false && !project_selected?)
    # if no_display conditions are not met, then display
    true
  end

  def tab_class?(tab)
    if @current_tab == tab
      'top_tab current'
    elsif !active_tab?(tab)
      'top_tab inactive'
    else
      'top_tab active'
    end
  end
end
