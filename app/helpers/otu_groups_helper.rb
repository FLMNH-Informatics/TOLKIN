module OtuGroupsHelper
  def change_position_link(move_type, otu_group_id, otu_id, current_project)
    url = change_position_project_otu_group_url :project_id => current_project.id,
      :id=> otu_group_id, :move => move_type, :otu_id => otu_id

    link_to_remote image_tag("#{move_type}.png", :border=>0), { :url => url, :method => :put }, { :id => "list_item_#{otu_id}_#{move_type}" }
  end

  def action_list_id
    "viewport_otu_groups_user_panel_otu_groups_action_list"
  end

  def otu_name_field
    @otu_name_field ||= OtuGroups::OtuNameAutoTextField.new({
      context:      self,
      model_object: @otu,
      parent:       viewport_window
   })
  end

  def user_panel
    OtuGroups::UserPanel.new({ parent: @viewport, context: self })
  end

  def viewport_window
    @viewport_window ||= General::Window.new
  end

  def user_panel_id
    "viewport_otu_groups_user_panel"
  end

  def link_to_table_link(img_filename, otu, move)
    link_to(image_tag(img_filename, :border=>0, :alt => move),
            { :action => :change_position,
              :project_id => current_project.id,
              :id => @otu_group.id,
              :otu_id => otu.id,
              :move => move },
            :method => :post,
            :class => 'move',
            :"data-move" => move
    )
  end

  def otu_groups_catalog
      OtuGroups::Catalog.new({
        context: self,
        parent: content_frame,
        collection: @otu_groups
    }).render_to_string
#    catalog('viewport_content_frame_otugroup_catalog', @requested, [
#        { :attribute => "name", :width => 250 },
#        { :attribute => "creator.label", :label => 'Owner', :width => 150 }
#      ], :count => @count
#    )
  end
end
