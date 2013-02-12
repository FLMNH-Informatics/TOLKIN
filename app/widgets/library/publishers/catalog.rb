
  module Library
    module Publishers
class Catalog < Templates::Catalog

  def initialize options
    options = {
      columns: [
        { :attribute => "name", :width => 250 }
      ]
    }.merge!(options)
    widgets({
        action_panel: { init: ->{Library::Publishers::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
      })
    super
  end
end
end
end
