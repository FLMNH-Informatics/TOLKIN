#class View::CheckList
#
#  def initialize(id, view, collection, display_attributes, options = { })
#    @id = id
#    @view = view
#    @collection = collection
#    @display_attributes = display_attributes
#    @options = options
#  end
#
#  def to_html
#
#    list_items = @collection.inject("") { |out, item|
#      out += @view.render(:partial => 'shared/check_list_item', :locals => {
#          :item_class => @view.cycle("even", "odd"),
#          :item => item,
#          :column_data => ("<td>" +
#              @display_attributes.collect { |attribute| item.try(attribute[:method]) }.join("</td><td>") + "</td>"
#          )
#        }
#      )
#    }
#
#    column_headings = "<th>" +
#      @display_attributes.collect { |attribute| attribute[:label] || attribute[:method].to_s.capitalize }.join("</th><th>") + "</th>"
#
#    @view.render :partial => 'shared/check_list', :locals => {
#      :check_list_id => @id,
#      :column_headings => column_headings,
#      :list_items => list_items,
#      :left_inactive => "inactive",
#      :right_inactive => @collection.size <= 20 ? "inactive" : "",
#      :start_index => "1",
#      :end_index => @collection.size <= 20 ? @collection.size : 20,
#      :count => @collection.size,
#      :collection => @collection,
#      :nav_colspan => @display_attributes.size + 1
#      }
#  end
#
#end
