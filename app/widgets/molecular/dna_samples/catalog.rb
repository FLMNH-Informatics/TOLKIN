module Molecular
    module DnaSamples
class Catalog < Templates::Catalog

  def initialize options
    options = {
      columns: [
        { :attribute => "taxon.label", :label => "Taxon", :width => 450 },
        { :attribute => "collection.label", :label => "Voucher", :width => 200 }
      ]
    }.merge!(options)
    widgets({
        action_panel: { init: ->{Molecular::DnaSamples::Catalogs::ActionPanel.new(parent: self, context: options[:context])} }
      })
    super
  end
end
end
end
