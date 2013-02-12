# coding:utf-8

class Matrices::VersioningPane < Widget
  attr_reader :changeset, :matrix

  def initialize options
    @matrix    ||= options[:matrix]    || fail("matrix required")
    @changeset ||= options[:changeset] || fail("changeset required")
    super
  end

  def changes_start_position
    @changeset.changes(:limit => 3).try(:first).try(:position) || 1
  end

  def view_history
    params[:controller].include?('morphology') ?
      context.link_to_remote("view history", :url => 'show_matrix_history_project_morphology_matrix_path', :method => :get)
    : context.link_to_remote("view history", :url => 'show_matrix_history_project_molecular_matrix_path', :method => :get)
  end

  def revert_all_changes
    out = ""
    out << "<a href='/projects/#{current_project.id}/#{params[:controller]}/#{params[:id]}/revert_all_changes' data-method='post' class='revert_all_changes'>revert all</a>"
  end

  def change_item_rows
    out = ""
    @changeset.changes(:limit => 3).each do |change|
      #out << "<li data-change-id='#{change.id}'>#{change.to_s} <a class='revert_change_link' onclick='revertChange(#{@changeset.id}, #{@matrix.id}, #{change.id})'>revert</a></li>"
      out << "<li data-change-id='#{change.id}'>#{change.to_s} "
      out << (params[:controller].include?('morphology') ? link_to("revert", revert_change_project_morphology_matrix_path({:changeset_item_id => change.id}), {:method => 'post'}) : link_to("revert", revert_change_project_molecular_matrix_path({:changeset_item_id => change.id}), {:method => 'post'}))
      out << "</li>"

    end
    out
  end

  def previous_version_link
    prev_address = @matrix.address.previous_address_if_exists
    if prev_address && prev_address.branch_position > 0
      params[:controller].include?('morphology') ?
        context.link_to('«', context.project_morphology_matrix_path(context.current_project, prev_address))
      : context.link_to('«', context.project_molecular_matrix_path(context.current_project, prev_address))
    else
      "<span style='color: grey'>«</span>"
    end
  end

  def next_version_link
    next_address = @matrix.address.next_address_if_exists
    #this is explicitly for morphology, might need to check if molecular or morphology
    if next_address
      params[:controller].include?('morphology') ? context.link_to('»', context.project_morphology_matrix_path(context.current_project, next_address)) : context.link_to('»', context.project_molecular_matrix_path(context.current_project, next_address))
    else
      "<span style='color: grey'>»</span>"
    end
  end


  def show_matrix_history_path
    #{ controller: context.controller_name, action: 'show_matrix_history', project: context.project.id, matrix: matrix.id, host: context.host }
    params[:controller].include?('morphology') ? context.controller.show_matrix_history_project_morphology_matrix_path : context.controller.show_matrix_history_project_molecular_matrix_path
  end

  def show_commit_changes_options_path
    #{ controller: context.controller_name, action: 'show_commit_changes_options', project: context.project.id, matrix: matrix.id, host: context.host }
    params[:controller].include?('morphology') ? context.controller.show_commit_changes_options_project_morphology_matrix_path : context.controller.show_commit_changes_options_project_molecular_matrix_path
  end

  def render_to_string
    render partial: 'shared/panes/versioning_pane'
  end

end
