module CurrentSelectionHelper
  include SessionStore::Accessors

  def display_current_selection
    session_get(:projects, @current_project.id, :current_selection) ? "" : "display: none"
  end
  
  def current_selection
    @current_selection ||= session_get(:projects, @current_project.id, :current_selection)
  end

  def current_selection_name
    if current_selection
#      if current_selection[:group]
##        key_cnt = current_selection[:group]
##        key_ = key_cnt.keys[0].to_s
##        key_ +"("+key_cnt[key_.to_sym].length.to_s+")"
#""
#      else
#        current_selection[:label]
#      end
      current_selection[:label]
    else
      ''
    end
  end
end
