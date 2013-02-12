module Morphology::MatricesHelper
  include MatricesHelper

  def matrix_name
    interact_mode == "browse" ? @timeline.name : text_field(:matrix, :name)
  end

  def matrix_description
    interact_mode == "browse" ? @timeline.description : text_area(:timeline, :description, :cols => 41, :rows => 3)
  end

  def order_link(type)
    if params[:action] == 'show'
      if params["sort_#{type}"] == "true"
        link_to %(Don't sort #{type})
      elsif type == "both"
        link_to("Sort both", :"sort_both" => true)
      else
        link_to( "Sort #{type == "otus" ? "OTUs" : "Characters"}", :"sort_#{type}" => true )
      end
    end
  end

  def color_swatches
    %(<table>
        <tr>
          <td><span class="titletext">Legend: </span></td>
          <td height="5px" width="10px" class="swatch a"></td>
          <td class="b" width="50px">(I)ncomplete</td>
          <td height="5px" width="10px" class="swatch b"></td>
          <td class="b" width="50px">(C)omplete</td>
          <td height="5px" width="10px" class="swatch c"></td>
          <td class="b" width="50px">(P)roblem</td>
          <td></td>
        </tr>
      <table>)
  end

  def row_builder motu
    @row = row_begin(motu.otu)
    @cells_array.each{|cell| @row += row_builder_cell(cell)} unless @cells_array.nil?
    @row
  end

  def row_builder_cell cell_array
    cell,otu_id,character_id = cell_array.first,cell_array.second,cell_array.third
    unless cell.nil?
      cell_class = "bt"
      cell_class << " #{subclass_for_status(cell.try(:status))}"
      link_text = ""
      link_text = cell.state_codings unless cell.nil?
      link_text = "----" if link_text.nil? or link_text.blank?
      extra_attrs = cell ? "data-cell-id='#{cell.id}'" : ""
      %(<td class = "#{cell_class}" id="c_#{otu_id}_#{character_id}" #{extra_attrs}>#{link_text}</td>)
    else
      %{<td class="bt a" id="c_#{otu_id}_#{character_id}" >----</td>}
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

  def matrix_empty_message
      "This matrix is currently empty <br />
       #{link_to "Edit this matrix", modify_matrix_project_morphology_matrix_path}" if @timeline.empty?#.characters.empty? && @timeline.otus.empty?
    end

  #autocomplete for matrix name
  def matrix_name_from_field
    @matrix_name_from_field || Morphology::Matrices::MatrixNameFromAutoTextField.new({
      context: self,
      model_object: @matrix,
      parent: viewport_window
      })
  end
  def matrix_name_to_field
    @matrix_name_from_field || Morphology::Matrices::MatrixNameAutoTextField.new({
      context: self,
      model_object: @matrix,
      parent: viewport_window
      })
  end

  #autocomplete for otu name
  def otu_name_field
    @otu_name_field ||= Morphology::Matrices::OtuNameAutoTextField.new({
      context: self,
      model_object: @otu,
      parent: viewport_window
    })
  end

  #autocomplete for character name
  def character_name_field
    @character_name_field ||= Morphology::Matrices::CharacterNameAutoTextField.new({
      context: self,
      model_object: @character,
      parent: viewport_window
    })
  end

  def viewport_window
    @viewport_window ||= General::Window.new
  end

  def action_list_id
    'viewport_morphology_matrices_user_panel_morphology_matrices_action_list'
  end

  def timeline_display_pane_id
    'viewport_morphology_matrices_user_panel_morphology_matrices_versioning_action_list'
  end

  def display_states_list_id
    'viewport_morphology_matrices_user_panel_morphology_matrices_display_states_list'
  end

  def user_panel
    Morphology::Matrices::UserPanel.new({ parent: @viewport, context: self })
  end

  def versioning_pane
    if RAILS_ENV == "production"
      Matrices::VersioningPane.new({
          context:   self,
          parent:    user_panel,
          matrix:    @matrix,
          changeset: @matrix.changeset
        }).render_to_string
    else
      Widgets::Matrices::VersioningPane.new({
          context:   self,
          parent:    user_panel,
          matrix:    @matrix,
          changeset: @matrix.changeset
        }).render_to_string
    end

  end

  def content_frame
    @content_frame ||= General::ContentFrame.new({ parent: viewport, context: self })
  end

  def matrices_catalog
    Morphology::Matrices::Catalog.new({
      collection: @matrix_views,
      context: self,
      parent: content_frame
                                      }).render_to_string
  end

  def row_begin otu
    "<tr id = \"r_#{otu.id}\" >" + morph_otus_display(otu)
  end

  def morph_otus_display(otu)
    %(<td id="rh_#{otu.id}" class="mh" #{otu.respond_to?(:color) ? 'style="background-color:' + otu.color + '"' : ""}>#{morph_otu_link otu}</td>)
  end

  def morph_otu_link(otu)
    %(<a href="#{url_for(:controller => '/otus', :action => 'show', :project_id => @project.id, :matrix_id => @timeline.to_param, :id => otu.id)}">#{otu.name}</a>)
    #link_to get_formatted_name(otu.name, false), url_for(:controller => '/otus', :action => 'show', :project_id => @project.id, :matrix_id => @timeline.to_param, :id => otu.id), :class => "matrix_heading_link"
  end

  def matrix_cell_hash(character,otu,cell)
    ch = {}
    cell_class = 'bt'
    cell_class << " #{subclass_for_status(cell.try(:status))}"
    ch[:class_name] = cell_class
    link_text = ""
    link_text = cell.state_codings unless cell.nil?
    if link_text.nil? or link_text.blank?
      link_text = "----"
    end
    ch[:innerHTML] = link_text
    td_id = "c_#{otu.id.to_s}_#{character.id.to_s}"
    ch[:td_id] = td_id
    ch[:data_cell_id] = cell.id
    ch
  end

  def matrix_cell(character, otu, cell)
    unless cell.nil?
      cell_class = 'bt'
      cell_class << " #{subclass_for_status(cell.try(:status))}"
      link_text = ""
      link_text = cell.state_codings unless cell.nil?
      if link_text.nil? or link_text.blank?
        link_text = "----"
      end
      extra_attrs = cell ? "data-cell-id='#{cell.id}'" : ""
      %(<td class="#{cell_class}" id="c_#{otu.id.to_s}_#{character.id.to_s}" #{extra_attrs}>#{link_text}</td>)
    else
      %(<td class="bt a" id="c_#{otu.id.to_s}_#{character.id.to_s}" >----</td>)
    end
  end

  def row_display
    unless @otus.nil?
      @rows = ""
      total_cells = @otus.length * @characters.length
      cell_counter = 1
      cell_index = 0
      otu_index = 0
      character_index = 0
      row_end = "</tr>"
      if total_cells != 0
        while cell_counter <= total_cells #increment until all cells are used
          @rows = @rows + row_begin(@otus[otu_index]) if character_index == 0 #new row only if character_index is 0
          if @cells[cell_index] && @cells[cell_index].character_id == @characters[character_index].id && @cells[cell_index].otu_id == @otus[otu_index].id
            #generate cell for existing cell
            @rows = @rows + matrix_cell(@characters[character_index], @otus[otu_index], @cells[cell_index])
            cell_index += 1
          else #generate blank cell
            @rows = @rows + matrix_cell(@characters[character_index], @otus[otu_index], nil)
          end
          if cell_counter%@characters.length == 0 #if cell_counter%start a new row
            @rows = @rows + row_end #need to end the previous row if starting a new row
            otu_index +=1
            character_index = 0
          else #continue with existing row
            character_index += 1
          end
          cell_counter += 1 #always increment
        end
      else
        @otus.each{|otu|@rows = @rows + row_begin(otu) + row_end}
      end
      raw @rows
    end
  end

  def old_row_display
    @rows = ""
    @timeline.otus.each do |otu|
      @rows = @rows + "<tr id =\"r_#{otu.id}\" >"
      if params[:otu_group_id]
        if otu.respond_to?(:color)
          @rows = @rows + (mol_otus_display otu)
          @timeline.characters.each do |chr|
            @rows = @rows + (chr_matrix_cell otu.id, chr.id)
          end
        end
      else
        @rows = @rows + (mol_otus_display otu)
        @timeline.characters.each do |chr|
          @rows = @rows + (chr_matrix_cell otu.id, chr.id)
        end
      end
    end
    raw @rows
  end

  def matrix_otu_link otu
    raw link_to get_formatted_name(otu.name, false), url_for(:controller => '/otus', :action => 'show', :project_id => @project.id, :matrix_id => @timeline.to_param, :id => otu.id)
  end

  def mol_otus_display otu
    raw %(<td class="mh" style="background-color:#{otu.respond_to?(:color) ? otu.color : ""}">#{matrix_otu_link otu}</td>)
  end



  def matrices_otu_group_catalog
    Morphology::Matrices::OtuGroups::Catalog.new({
        collection: @otu_groups,
        context: self,
        parent: content_frame,
        has_filter_set: false
      }).render_to_string
  end


  def id_for_otu_groups_pane
    case "#{request[:controller]}##{request[:action]}"
    when /^\/matrices/                   then 'viewport_morphology_matrices_user_panel_matrices_otu_groups_pane'
    else 'matrices_otu_groups_pane'
    end
  end

  def dates_list
    cell_dates = Morphology::Matrix::Cell.where('timeline_id = ?', params[:id]).order('create_date DESC').inject([]){|memo, cell| cell.create_date.nil? ? memo : memo.push(cell.create_date.to_date)}
    character_dates = Morphology::Matrix::MatricesCharacters.where('timeline_id = ? and delete_date is NULL', params[:id]).order('create_date DESC').inject([]){|memo, char| char.create_date.nil? ? memo: memo.push(char.create_date.to_date)}
    otu_dates = Morphology::Matrix::MatricesOtus.where('timeline_id = ? and delete_date is NULL', params[:id]).order('create_date DESC').inject([]){|memo, otu| otu.create_date.nil? ? memo : memo.push(otu.create_date.to_date)}
    all_dates = cell_dates | character_dates | otu_dates
    all_dates.sort.reverse
  end

end
