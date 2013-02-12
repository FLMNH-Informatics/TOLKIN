  module Molecular
    module Alignments
class Catalog < Templates::Catalog

  def initialize options
    options = {
      columns: [
        { :attribute => "name", :width => 150 },
        { :attribute => "description",   :label => 'Description', :width => 250 },
        { :attribute => "creator.label", :label => 'Owner', :width => 100 }
      ]
    }.merge!(options)
    widgets({
        action_panel: { init: ->{Molecular::Alignments::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
      })
    super
  end
end
end
end
