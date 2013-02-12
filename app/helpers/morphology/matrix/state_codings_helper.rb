module Morphology::Matrix::StateCodingsHelper
  def change_item_rows
    out = ""
    @changeset.changes(:limit => 3).each do |change|
      out << "<li data-change-id='#{change.id}'>#{change.to_s}"
      out << "<a href='/projects/#{current_project.id}/morphology/matrices/#{params[:matrix_id]}/revert_change?changeset_item_id=#{change.id}' data-method='post' class='revert_change_link'>revert</a></li>"
    end
    out
  end
  def revert_all_changes
    out = ""
    out << "<a href='/projects/#{current_project.id}/morphology/matrices/#{params[:matrix_id]}/revert_all_changes' data-method='post' class='revert_all_changes'>revert all</a>"
  end

  def changes_start_position
    @changeset.changes(:limit => 3).try(:first).try(:position) || 1
  end
end
