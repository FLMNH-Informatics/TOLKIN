module Molecular::MatricesHelper
  include MolMatrixCell

  def matrices_catalog
    Molecular::Matrices::Catalog.new({
          collection: @matrix_views,
          context: self,
          parent: content_frame
        }).render_to_string
  end

  def color_swatches
    if @current_project.mol_matrix_cell_statuses.empty?
      %w(Incomplete Tentative Problem Complete).each_with_index { |status_name, index| @current_project.mol_matrix_cell_statuses.create({:name => status_name, :position => index + 1}) }
    end
    @current_project.mol_matrix_cell_statuses.map{ |status| raw("<td class='swatch #{subclass_for_status(status.name)}'></td><td class='b'>#{status.name}</td>") }.join
  end

  def order_link(type)
    if params[:action] == 'show'
      if params["sort_#{type}"] == "true"
        link_to %(Don't sort #{type})
      elsif type == "both"
        link_to("Sort both", :"sort_both" => true)
      else
        link_to( "Sort #{type == "otus" ? "OTUs" : "Markers"}", :"sort_#{type}" => true )
      end
    end
  end

  def test_markers
    debugger
    @markers
  end

  def user_panel_id
    "viewport_molecular_matrices_user_panel"
  end

  def timeline_display_pane_id
    "viewport_molecular_matrices_user_panel_molecular_matrices_versioning_action_list"
  end

  def versioning_action_list_id
    'viewport_molecular_matrices_user_panel_molecular_matrices_versioning_action_list'
  end

  def action_list_id
    'viewport_molecular_matrices_user_panel_molecular_matrices_action_list'
  end

  def matrix_empty_message
    "This matrix is currently empty <br />
     #{link_to "Edit this matrix", modify_matrix_project_molecular_matrix_path, {:class => "nopad"}}" if @timeline.markers.empty? && @timeline.otus.empty?
  end

  def link_to_genbank cell
    %(<a target='_blank' href='#{genbank_href cell}' alt='gb'>#{respond_to?("image_tag") ? 
      image_tag('genbank.gif', {:size => "11x11", :class => "gb_hov_mini"}) : 
      "<img class='gb_hov_mini' width='11' height='11' src='/images/genbank.gif' alt='Genbank'>"}</a>)
  end

  def genbank_href cell
    if cell.primary_sequence_locus
      %(http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=nucleotide&cmd=search&term=#{cell.primary_sequence_locus})
    end
  end

  def row_builder motu
    @row = row_begin(motu.otu)
    @cells_array.each{|cell| @row += row_builder_cell(cell)} unless @cells_array.nil?
    @row
  end

  def row_builder_cell cell_array
    cell,otu_id,marker_id = cell_array.first,cell_array.second,cell_array.third
    unless cell.nil?
      cell_class = "bt"
      cell_class << " #{subclass_for_status(cell.status_text ? cell.status_text : "Incomplete")}"
      link_text = cell.responsible_user_initials ? cell.responsible_user_initials : nil
      link_text = cell.status ? cell.status.name : '----' if (link_text.blank? || link_text.nil?)
      extra_attrs = "data-cell-id='#{cell.id}'"
      seq_count = cell.sequence_count.nil? ? 0 : cell.sequence_count
      seq_icon = cell.primary_sequence_locus.nil? ? "" : link_to_genbank(cell)
    end
    %(<td class="#{cell_class || "bt a"} just_loaded" id="#{"c_#{otu_id}_#{marker_id}"}" #{extra_attrs || ""}><div class="cell_div">#{link_text || "----"} #{seq_icon || ""}<div class="seq_count">#{(seq_count unless seq_count == 0) || ""}</div><div class="cell_checkbox"></div></div></td>)
  end

  def matrix_cell marker, otu, cell
    unless cell.nil?
      cell_class = "bt"
      cell_class << " #{subclass_for_status(cell.status_text ? cell.status_text : "Incomplete")}"
      link_text = cell.responsible_user_initials ? cell.responsible_user_initials : nil
      link_text = cell.status ? cell.status.name : '----' if (link_text.blank? || link_text.nil?)
      extra_attrs = "data-cell-id='#{cell.id}'"
      seq_count = cell.sequence_count.nil? ? 0 : cell.sequence_count
      seq_icon = cell.primary_sequence_locus.nil? ? "" : link_to_genbank(cell)
    end
    %(<td class="#{cell_class || "bt a"}" id="#{"c_#{otu.id}_#{marker.id}"}" #{extra_attrs || ""}><div class="cell_div">#{link_text || "----"} #{seq_icon || ""}<div class="seq_count">#{(seq_count unless seq_count == 0) || ""}</div><div class="cell_checkbox"></div></div></td>)
  end

  def row_begin otu
    "<tr id = \"r_#{otu.id}\" >" + mol_otus_display(otu)
  end

  def mol_otus_display otu
    %(<td id="rh_#{otu.id}" class="mh" #{otu.respond_to?(:color) ? 'style="background-color:' + otu.color + '"' : ""}>#{mol_matrix_otu_link otu}</td>)
  end

  def row_display
    unless @otus.nil?
      @rows = ""
      total_cells  = @otus.length * @markers.length
      cell_counter = 1
      cell_index   = 0
      otu_index    = 0
      marker_index = 0
      row_end      = "</tr>"
      if total_cells != 0
        while cell_counter <= total_cells  #increment until all cells are used
          @rows = @rows + row_begin(@otus[otu_index]) if marker_index == 0 #new row only if marker_index is 0
          if @cells[cell_index] && @cells[cell_index].marker_id == @markers[marker_index].id && @cells[cell_index].otu_id == @otus[otu_index].id
            #generate cell for existing cell
            @rows = @rows + matrix_cell(@markers[marker_index], @otus[otu_index], @cells[cell_index])
            cell_index += 1
          else
            #generate blank cell
            @rows = @rows + matrix_cell(@markers[marker_index], @otus[otu_index], nil)
          end
          if cell_counter%@markers.length == 0 #if cell_counter%start a new row
            @rows = @rows + row_end #need to end the previous row if starting a new row
            otu_index +=1
            marker_index = 0
          else #continue with existing row
            marker_index += 1
          end
          cell_counter += 1 #always increment
        end
      else
        @otus.each{ |otu| @rows = @rows + row_begin(otu) + row_end }
      end
      raw @rows
    end
  end

  def modify_matrix_controls(obj)
    obj_type = obj.class.to_s.split('::').last.underscore.split('_').last.singularize
    output = ""
    html_data_obj = "data-" + obj_type + "-id"
    [
      ["f","move_to_top"],
      ["u","move_higher"],
      ["d", "move_lower"],
      ["la", "move_to_bottom"],
      ["x", "remove_from_list"]
    ].each do |movement|
      output << %(<td class="b hovhand">#{image_tag(movement.first + ".png", { :border => 0,
                                                                       :"data-action" => 'change_position',
                                                                       :"data-project-id" => @project.id,
                                                                       :"data-matrix-id" => @timeline.id,
                                                                       html_data_obj.to_sym => obj.try(obj_type).id,
                                                                       :"data-type" => obj_type,
                                                                       :"data-move" => movement.last })}</td>)
    end
    output
  end



  def mol_matrix_otu_link otu
    %(<a href="#{url_for(:controller => '/otus', :action => 'show', :project_id => @project.id, :matrix_id => @timeline.to_param, :id => otu.id)}">#{otu.name}</a>)
    #link_to otu.name, url_for(:controller => '/otus', :action => 'show', :project_id => @project.id, :matrix_id => @timeline.to_param, :id => otu.id)
  end

  def dates_list
    cell_dates = Molecular::Matrix::Cell.where('timeline_id = ?', params[:id]).order('create_date DESC').inject([]){|memo,cell| cell.create_date.nil? ? memo : memo.push(cell.create_date.to_date) } #map{|cell| cell.created_at unless cell.created_at.nil? }
    marker_dates = Molecular::Matrix::MatricesMarkers.where('timeline_id = ? and delete_date is NULL', params[:id]).order('create_date DESC').inject([]){|memo, marker| marker.create_date.nil? ? memo : memo.push(marker.create_date.to_date)}#.map{|marker|marker.create_date unless marker.create_date.nil?}
    otu_dates = Molecular::Matrix::MatricesOtus.where('timeline_id = ? and delete_date is NULL', params[:id]).order('create_date DESC').inject([]){|memo, otu| otu.create_date.nil? ? memo : memo.push(otu.create_date.to_date)}#.map{|otu|otu.create_date unless otu.create_date.nil?}
    all_dates = cell_dates | marker_dates | otu_dates
    all_dates.sort.reverse
  end


  def matrix_name
    interact_mode == "browse" ? @timeline.name : text_field(:matrix, :name)
  end

  def matrix_description
    interact_mode == "browse" ? @timeline.description : text_area(:timeline, :description, :cols => 41, :rows => 3)
  end


  def otu_name_field
    @otu_name_field ||= Molecular::Matrices::OtuNameAutoTextField.new({
      context: self,
      model_object: @otu,
      parent: viewport_window
    })
  end

  #autocomplete for marker name
  def marker_name_field
    @marker_name_field ||= Molecular::Matrices::MarkerNameAutoTextField.new({
      context: self,
      model_object: @marker,
      parent: viewport_window
    })
  end

  def marker_checkbox_list
    list = ""
    all_marker_names = (@project.markers.collect { |mrk| mrk.name }).sort {|a,b| a.downcase <=> b.downcase }
    matrix_markers = @timeline.matrices_markers.in_list.collect{|mm| mm.marker.name }.compact
    #matrix_markers = @timeline.markers.collect { |mrk| mrk.name }
    absent_marker_names = all_marker_names.reject{|mrk| matrix_markers.include?(mrk)}.uniq
    absent_marker_names.each {|name| list = list + "<label for='chk_#{name}' title='#{name}'><input type='checkbox' id='chk_#{name}' value='#{name}' name='marker_names[]'>#{truncate(name, :length => 20)}</label><br />"}
    raw list
  end

  def viewport_window
    @viewport_window ||= General::Window.new
  end

  def render_matrix_list_items
    render :partial => "shared/list_items", :locals => {
      :title => "Matrices Listing",
      :items_to_list => @matrix_branches,
      :attributes => @attributes,
      :attribute_display_properties => @attribute_properties,
      :options => { :id => 'matrices_listing' } }
  end


  def user_panel
    Molecular::Matrices::UserPanel.new({ parent: @viewport, context: self })
  end

  def versioning_pane
    if RAILS_ENV == "production"
      Matrices::VersioningPane.new({
          context:   self,
          parent:    user_panel,
          matrix:    @timeline,
          changeset: @timeline.changeset
        }).render_to_string
    else
      Widgets::Matrices::VersioningPane.new({
          context:   self,
          parent:    user_panel,
          matrix:    @timeline,
          changeset: @timeline.changeset
        }).render_to_string
    end
  end


  def sorted_markers
    @matrix.markers.collect{ |m| m.id }.inject({}) do |memo, id|
      memo[id] = Molecular::Matrix::Cell.where( 'marker_id = ? and checkpoint_id = ?', id, @timeline.checkpoint.id ).collect{ |cell| cell.id }
      memo
    end
  end


  def matrices_otu_group_catalog
     Molecular::Matrices::OtuGroups::Catalog.new({
      collection: @otu_groups,
      context: self,
      parent: content_frame,
      has_filter_set: false
    }).render_to_string
  end


  def id_for_otu_groups_pane
    case "#{request[:controller]}##{request[:action]}"
      when /^\/mol_matrices/                   then 'viewport_molecular_matrices_user_panel_matrices_otu_groups_pane'
      else 'matrices_otu_groups_pane'
    end
  end

  def status_select
    select("cell", "status_id", Molecular::Matrix::Cell::Status.for_project(current_project).collect { |s| [s.name, s.id] } )
  end

end
