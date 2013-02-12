module UserPanelHelper
  def render_user_panel_if_present
    should_display = case "#{request[:controller]}##{request[:action]}"
      when /^molecular\/alignments/      					     then false
      when /^insd\/seqs/                 					     then false
      when /^molecular\/dna_samples/     					     then false
      when /^molecular\/primers/         					     then false
      when /^molecular\/plastome\/tables/ 					   then false
      when /^taxa#tree_view/             					     then false
      when /^taxa/                       					     then false
      when /^otus#index/                  					   then false
      when /^otus#show/                   					   then false
      when /^otus/                        					   then true
      when /^otu_groups/                   					   then false
      when /^molecular\/matrices#index/   					   then false
      when /^molecular\/matrices#show/         			   then true
      when /^molecular\/matrices#modify_matrix/        then true
      when /^molecular\/matrices#view_by_date/         then true
      when /^molecular\/matrices#bulk_sequence_exporter/ 	then false
      when /^morphology\/matrices#index/  					then false
      when /^morphology\/matrices#show/         			   then true
      when /^morphology\/matrices#modify_matrix/        then true
      when /^morphology\/matrices#view_by_date/         then true
      when /^morphology\/matrices#bulk_sequence_exporter/ 	then false
      when /^morphology\/characters#show/ 	then true unless @character.timelines.empty?
    else                                      					 false
    end
    should_display ? render(:partial => 'shared/user_panel') : ''
  end

  def id_for_user_panel
    case "#{request[:controller]}##{request[:action]}"
      when /^molecular\/insd\/seqs/        then 'viewport_insd_seqs_user_panel'
      when /^molecular\/alignments#index$/ then 'viewport_molecular_alignments_user_panel'
      when /^molecular\/dna_samples#/      then 'viewport_molecular_dna_samples_user_panel'
      #when /^molecular\/matrices#[a-zA-Z]+/         then 'viewport_molecular_matrices_user_panel'
      when /^molecular\/matrices/          then 'viewport_molecular_matrices_user_panel'
      when /^molecular\/primers#/          then 'viewport_molecular_primers_user_panel'
      when /^taxa/                         then 'viewport_taxa_user_panel'
      when /^morphology\/matrices/         then 'viewport_morphology_matrices_user_panel'
      when /^otus/                         then 'viewport_otus_user_panel'
      when /^otu_groups/                   then 'viewport_otu_groups_user_panel'
      else 'user_panel'
    end
  end

  def display_user_panel
    panes_to_display = case "/#{request[:controller]}##{request[:action]}"
      when /^\/molecular\/alignments/         				        then [ :action_list_pane, :shopping_cart_pane ]
      when /^\/molecular\/dna_samples/        				        then [ :action_list_pane ]
      when /^\/molecular\/primers/            				        then [ :action_list_pane ]
      when /^\/molecular\/matrices#index$/    				        then [ :action_list_pane ]
      when /^\/molecular\/matrices#show/           			      then [ :timeline_display_pane, :action_list_pane ]
      when /^\/molecular\/matrices#view_by_date/              then [ :action_list_pane ]
      when /^\/molecular\/matrices#modify_matrix/             then [ :timeline_display_pane, :action_list_pane ]
      when /^\/molecular\/matrices#bulk_sequence_exporter$/ 	then [ :action_list_pane ]
      when /^\/workflows/                     				        then [ :action_list_pane, :tree_view_pane ]
      #when /^\/morphology\/characters/        				        then [ :action_list_pane, :shopping_cart_pane ]
      when /^\/morphology\/chr_groups/        				        then [ :action_list_pane ]
      when /^\/morphology\/matrices#show/   				          then [ :timeline_display_pane, :action_list_pane, :state_display_list ]
      when /^\/morphology\/matrices#view_by_date/             then [ :action_list_pane, :state_display_list ]
      when /^\/morphology\/matrices#modify_matrix/            then [ :timeline_display_pane, :action_list_pane ]
      when /^\/taxa/
        case request[:action]
          when 'tree_view'                						then [ :current_selection, :shopping_cart_pane ]
#         when 'index'                    						then [ :current_selection, :shopping_cart_pane ]
        else                                 						 []
        end
      when /^\/otus/
        case request[:action]
          when 'index'                        then [ :otu_action_list ]#, :shopping_cart_pane ]
          else                                     [ :otu_pane_old ]
        end
      else                                       [ :action_list_pane ]
    end

    window_classes = [ :user_panel, :widget ]
    window_classes << case request[:controller]
    when 'workflows' then :workflows
    when 'otus' then :otus
    else :standard
    end

    for_response = ""
    panes_to_display.each do |pane|
      if pane.kind_of? Symbol
        for_response << render(partial: "shared/panes/#{pane.to_s}", locals: { parent_id: id_for_user_panel })
      else
        for_response << pane
      end
    end

    # add nav window around content
    for_response = content_tag('div', raw(for_response), :id => id_for_user_panel, :class => "#{window_classes.join(' ')}")
    for_response

  end

  def user_panel_options_list
    options_links = case "/"+request[:controller]
    when '/taxa'
      case request[:action]
      when 'index'
      [
        "Create Taxon at Root",
        "Delete Selected"
      ]
      end
      when '/morphology/characters'
        case request[:action]
          when 'show'
            sorted = []
            sorted = @character.timelines.sort_by{ |timeline| [timeline.name, timeline.version_number] } unless @character.timelines.empty?
            sorted.empty? ? ['No matrices'] : sorted.flatten.map{|timeline|
              name = timeline.name
              title = name
              title = name + " (v" + timeline.version_number.to_s + ")" unless timeline.number_of_versions == 1
              [link_to(truncate(title, :length => 20), project_morphology_matrix_path(current_project, timeline)), link_to('(Character)', project_morphology_matrix_character_path(current_project,timeline,@character), :style => "float:right;padding-right:9px;"), title.length]
            }
        end
    when '/morphology/matrices'
      case request[:action]
        when 'index'
          [
            link_to_remote('New Matrix', :url => new_project_matrix_path(@project), :method => :get),
            link_to_remote('Import Matrix', :url => new_project_nexus_dataset_path(@project), :method => :get),
            link_to('Delete Selected', "javascript:void(0)", :id=>"lnk_del_sel"),
            link_to('Modify Matrix', "javascript:void(0)", :id=>"sp_modify_matrix"),
            link_to_remote('Merge Matrices', :url => show_merge_window_project_matrices_path(@project), :method => :get),
            link_to_remote('Designate Submatrix', :url => show_designate_submatrix_window_project_matrices_path(@project), :method => :get)
          ]
        when 'show'
          [
            link_to('Edit Characters and Otus', modify_matrix_project_morphology_matrix_path),
            "Copy this matrix",
            "Export Nexus file"
          ].map{ |text| text.class == String ? link_to(text, '#', { :id => text.gsub(" ", "_"), :class => text.gsub(" ", "_") } ) : text }
        when 'modify_matrix'
          [
            link_to('View Matrix', project_morphology_matrix_path)
          ].map{ |text| text.class == String ? link_to(text, '#', { :id => text.gsub(" ", "_"), :class => text.gsub(" ", "_") } ) : text }

        when "view_by_date"
          [
            link_to('View current matrix', project_morphology_matrix_path),
            link_to('Edit Characters and Otus', modify_matrix_project_morphology_matrix_path),
            "Copy this matrix",
            "View history by date",
            "Export Nexus file"
          ].map{ |text| text.class == String ? link_to(text, '#', { :id => text.gsub(" ", "_"), :class => text.gsub(" ", "_") } ) : text }

          #[
          #  link_to('Show Matrix', project_morphology_matrix_path(current_project.id, @matrix.id)),
          #  #link_to_remote('Add Character/Group old', :url => add_character_project_morphology_matrix_path(current_project.id, @matrix.id, :type => 'new'), :method => :get),
          #  link_to('Add Character/Group', optional_matrix_resource_url(:controller => '/morphology/matrices', :action => 'show_add_character', :matrix_id => params[:matrix_id], :project_id => params[:project_id], :id => params[:id])),
          #  link_to_remote('Add Otu/Group', :url => add_otu_project_morphology_matrix_path(current_project.id, @matrix.id, :type => 'new'), :method => :get),
          #  link_to('Delete selected', "#", :id=>"lnk_del_sel")
          #]
      end
    when '/molecular/alignments'
      [
        'New Alignment',
        'Delete Selected'
      ]
    when '/molecular/dna_samples'
      [
        'New Raw DNA',
#        link_to_remote('New Raw DNA', :url => new_project_molecular_dna_sample_path, :method => :get),
        link_to_function('Delete Selected', "if(confirm('Are you sure you would like to delete these raw DNA sequences?')){
                                                                                 $('list_items_form').writeAttribute('action','#{delete_selected_project_molecular_dna_samples_path(params[:project_id])}');
                                                                                 $('list_items_form').writeAttribute('method','post');
                                                                                 $('list_items_form').submit();
                                                                                 $('list_items_form').writeAttribute('action','');
                                                                                }")
      ]
    when '/molecular/primers'
      [
        'New Primer'
      ]
    when '/molecular/insd/seqs'
      [
        link_to_remote('New DNA Sequence', :url => new_project_molecular_sequence_path, :method => :get),
         #Genbank sequence submission changes - START
        'Export DNA Sequence',
        link_to_remote('Import Fasta File', :url => browse_fasta_file_project_molecular_sequences_path, :method => :get),
         #Genbank sequence submission changes - END
#        link_to_function('Delete Selected',
#          "if(confirm('Are you sure you would like to delete these sequences?')){
#                                                                                 $('list_items_form').writeAttribute('action','#{delete_selected_project_bioentries_path(params[:project_id])}');
#                                                                                 $('list_items_form').writeAttribute('method','post');
#                                                                                 $('list_items_form').submit();
#                                                                                 $('list_items_form').writeAttribute('action','');
#                                                                                }")
      ]
    when '/molecular/plastome/tables'
      case request[:action]
      when "show"
        [
          link_to_remote('Edit Name / Description', :url => show_details_project_plastome_table_path, :method => :get),
          link_to('Edit Taxa', project_plastome_table_taxa_path(:table_id => params[:id]), :id => :edit_plastome_table_taxa_link, :class => :link_to_windowed,
            :window_id => window_id(:controller => '/molecular/plastome/table/taxa', :action => 'index') ),
          link_to('Delete', "#")
        ]
      when "design"
        [
          link_to('Show Table', project_plastome_table_path),
          link_to('Add Taxon',  new_project_plastome_table_taxon_path(:table_id => params[:id]), :id => :add_taxon_link, :class => :link_to_windowed,
            :window_id => window_id(:controller => '/molecular/plastome/table/taxa', :action => 'new') ),
          link_to('Delete selected', "#")
        ]
      else
        [
          link_to_remote('New Table', :url => new_project_plastome_table_path, :method => :get),
          link_to_function('Delete Selected', "if(confirm('Are you sure you would like to delete these plastome tables?')) { $('list_items_form').request(); }")
        ]
      end
    when '/molecular/matrices'
      case request[:action]
        when "show"
          [
            link_to('Edit Markers and Otus', modify_matrix_project_molecular_matrix_path),
            link_to("Bulk Sequence Exporter", bulk_sequence_exporter_project_molecular_matrix_path),
            "Copy this matrix",
            "Autofill matrix"
          ].map{ |text| text.class == String ? link_to(text, '#', { :id => text.gsub(" ", "_"), :class => text.gsub(" ", "_") } ) : text }
        when "modify_matrix"
          [
            link_to('View Matrix', '#'),
            link_to("Bulk Sequence Exporter", bulk_sequence_exporter_project_molecular_matrix_path),
          ].map{ |text| text.class == String ? link_to(text, '#', { :id => text.gsub(" ", "_"), :class => text.gsub(" ", "_") } ) : text }
        when "view_by_date"
          [
            link_to('Edit Markers and OTUs', modify_matrix_project_molecular_matrix_path),
            link_to("Bulk Sequence Exporter", bulk_sequence_exporter_project_molecular_matrix_path(:date => params[:date])),
            "Copy this matrix",
            "View history by date"
          ].map{ |text| text.class == String ? link_to(text, '#', { :id => text.gsub(" ", "_"), :class => text.gsub(" ", "_") } ) : text }
      end
    when '/workflows'
      [
        link_to('Create New Workflow', "\#")
      ]
    when '/otu_groups'
      ["Add Otu to Group", "Remove Selected from Group"].map{|text| text.class == String ? link_to(text, '#', {:id => text.gsub(" ", "_"), :class => text.gsub(" ", "_") } ) : text }
    else [ ]
    end
    display = "<ul id='#{action_list_id}' class='action_list widget'>"
    unless options_links.nil?
      unless options_links.first.class == Array
        options_links.each{ |link|
          display << content_tag('li', link, :class => link.match(/(>)([\[\]\:\(\)\_a-zA-Z 0-9\/\\]+)(<)/).nil? ? "" : link.match(/(>)([\[\]\:\(\)\_a-zA-Z 0-9\/\\]+)(<)/)[2].gsub(" ", "_") )
        }
      else
        #max_length = options_links.map{|ar| ar[2] }.sort.last
        options_links.each{|link_array|
          display << content_tag('li', link_array[0] + link_array[1], :class => "matrix_and_character_link")
        }
      end
    end

    raw display << '</ul>'
  end

  def timelines_display
    debugger
    "test"
  end
end
