# coding: utf-8
require 'taxa/tree_views/action_panel'
class Taxa::TreeView < Widget
  def initialize options
    @root_taxa ||= options[:root_taxa] || fail('root taxa not provided')
    super
  end

  def node_name_element(taxon)
    div_classes = [ 'tree_view_node_name' ]
    div_classes.push 'accepted_name' if taxon.namestatus.try(:status) == 'accepted_name'
    span_class = context.current_selection == taxon ? " class='selected'" : ''
    return "<div class='#{div_classes.join(' ')}'><span#{span_class}>#{taxon.name}</span></div>"
  end

  def node_children(taxon)
#    if @selected_taxon && @selected_taxon.left_value > taxon.left_value && @selected_taxon.right_value < taxon.right_value
#      #render :partial => 'node', :collection => taxon.children.find(:all, :include => :namestatus)
#      taxon.children.find(:all, :include => :namestatus, :select => 'id,name,namestatus_id,parent_taxon_id,right_value,left_value').inject("") { |memo, child|
#      memo << %{<tr class="tree_view_node" id="taxon_#{child.id}_node">
#          <td class="tree_view_expander">#{expander_for(child)}</td>
#          <td>#{node_name_element(child)}
#            <table class="tree_view_node_children">#{node_children(child)}</table>
#          </td>
#        </tr>}
#      }
#    end
  end

  def expander_for(node)
    if(node.has_descendants?)
      if(@selected_taxon && @selected_taxon.descendant_of?(node))
        "‒"
      else
        "+"
      end
    else
      ""
    end
  end

  def render_to_string
    to_s
  end

  def action_panel
    @action_panel ||= Taxa::TreeViews::ActionPanel.new({ parent: self, context: context })
  end

  def to_s
    %{<div id='#{id}' class='tree_view widget'>
        #{action_panel}
        <table>
          #{render partial: 'taxa/node', collection: @root_taxa }
        </table>
      </div>
    }
  end
end