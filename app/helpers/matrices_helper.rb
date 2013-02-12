# coding:utf-8

module MatricesHelper
  STANDARD_STATUS_TO_SUBCLASS_CONVERT = {
    :'incomplete' => 'a',
    :'complete'   => 'b',
    :'problem'    => 'c',
  }

#  def character_name_field
#    @character_name_field ||= Morphology::Matrices::CharacterNameAutoTextField.new(
#      context: self,
#      model_object: @character,
#      parent: content_frame
#    )
#  end

  def link_to_previous
    # shouldn't use « symbol use << instead
    @timeline.previous_version.nil? ? "<span style='color: grey'><<</span>".html_safe :
      link_to("<<",
              @timeline.class.name.start_with?('Mor') ? project_morphology_matrix_path(current_project, @timeline.previous_version) : project_molecular_matrix_path(current_project, @timeline.previous_version)
      )
  end

  def link_to_first
    @timeline.previous_version.nil? ? "<span style='color: grey'>|<</span>".html_safe :
      link_to("|<",
              @timeline.class.name.start_with?('Mor') ? project_morphology_matrix_path(current_project, @timeline.first_version) : project_molecular_matrix_path(current_project, @timeline.first_version))
  end

  def link_to_last
    @timeline.is_last_version? ? "<span style='color: grey'>>|</span>".html_safe :
      link_to(">|",
              @timeline.class.name.start_with?('Mor') ? project_morphology_matrix_path(current_project, @timeline.last_version) : project_molecular_matrix_path(current_project, @timeline.last_version))
  end

  def link_to_next
    # shouldn't use » symbol
    @timeline.next_version.nil? ? "<span style='color: grey'>>></span>".html_safe :
      link_to(">>",
              @timeline.class.name.start_with?('Mor') ? project_morphology_matrix_path(current_project, @timeline.next_version) : project_molecular_matrix_path(current_project, @timeline.next_version)
      )
  end

  def version_change_control_options
    current_id  = @timeline.id.to_s
    matrix_type = @timeline.class.name.start_with?('Mor') ? "/morphology/" : "/molecular/"
    url = "/projects/" + current_project.project_id.to_s + matrix_type + "matrices/"
    options = (1..@timeline.number_of_versions).inject([]) do |memo,num|
      timeline_id = @timeline.sorted_versions[num - 1].id.to_s
      memo << ((current_id == timeline_id) ? [num, timeline_id] : [num, timeline_id, {:onclick => 'window.location = ' + url + timeline_id}])
      memo
    end
    options_for_select(options, [@timeline.version_number, @timeline.id.to_s])
  end

  def matrix_show_link(project, matrix)
    object_history = matrix.object_history
    branch_number = matrix.branch.branch_number
    branch_position = matrix.branch_position
    link_to 'Show', show_project_morphology_matrix_path(project.id, object_history, branch_number, branch_position)
  end

  def matrix_edit_link(project, matrix)
    object_history = matrix.object_history
    branch_number = matrix.branch.branch_number
    branch_position = matrix.branch_position
    link_to 'Edit', edit_project_morphology_matrix_path(project.id, object_history, branch_number, branch_position)
  end

  def previous_version_link
    prev_address = @matrix.address.previous_address_if_exists
    prev_address && prev_address.branch_position > 0 ?  link_to('«', project_morphology_matrix_path(:project_id => @project.id, :id => prev_address)) : "<span style='color: grey'>«</span>"
  end

  def next_version_link
    debugger
    next_address = @matrix.address.next_address_if_exists
    next_address ?  link_to('»', project_morphology_matrix_path(:project_id => @project.id, :id => next_address)) : "<span style='color: grey'>»</span>"
  end

  def subclass_for_status status
    status ||= 'incomplete'
    convert  = STANDARD_STATUS_TO_SUBCLASS_CONVERT
    convert[status.to_sym]
  end

  def chr_matrix_cell otu_id, chr_id
    cell_class = "bt"
    cell = @timeline.cells.fetch(chr_id, otu_id)
#    if (cell = @matrix.codings.fetch(chr_id, otu_id)).nil?
#      cell_style = cell_style + "i"
#    else
#      # dirty hack to save us all - how these cells have no status?
#      if !cell.status
#        cell.status = 'incomplete'
#        cell.save!
#      end
    cell_class << " #{subclass_for_status(cell.try(:status))}"
#    end

    link_text=""
    link_text = cell.codings unless cell.nil?
    if link_text.nil? or link_text.blank?
      link_text = "----"
    end
    extra_attrs = cell ? "data-cell-id='#{cell.id}'" : ""

    id= "c_#{otu_id.to_s}_#{chr_id.to_s}"
    %(<td class="#{cell_class}" id="#{id}" #{extra_attrs}>#{link_text}</td>)
  end
end
