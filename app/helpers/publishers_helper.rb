# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'library/publishers/catalog'
module PublishersHelper
  def publishers_catalog
        Widgets::Library::Publishers::Catalog.new({
      collection: @collection,
      context: self,
      parent: content_frame
    }).render_to_string
#    catalog('viewport_content_frame_citation_publisher_catalog', @requested, [
#        { :attribute => "name", :width => 250 },
#      ], :count => @count
#    )
  end
end
