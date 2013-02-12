#class RemoteLinkRenderer < WillPaginate::LinkRenderer
#  def prepare(collection, options, template)
#    @remote = options.delete(:remote) || {}
#    super
#  end
#
#protected
#  def page_link(page, text, attributes = {})
#    @template.link_to_remote(text, {:url => url_for(page), :method => :get}.merge(@remote))
#  end
#end
class RemoteLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
  #attr_accessor :callback
  def link(text, target, attributes = {})
    attributes["data-remote"] = true
    attributes["class"] = "paginate_link"
    super
  end
end