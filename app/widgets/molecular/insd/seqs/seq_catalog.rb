class Molecular::Insd::Seqs::SeqCatalog < Templates::Catalog
  def initialize options
    options = {columns: [ { attribute: 'organism',   width: 137 },{ attribute: "markers_fulltext", label: "Markers",     width: 112 },{ attribute: "sequence",    width: 152 }  ],data_id: 'pk',limit:10}.merge!(options)
    widgets({
      action_panel: { init: ->{ Molecular::Insd::Seqs::SeqCatalogs::ActionPanel.new({ parent: self, context: options[:context] }) }},
    })
    super
  end
end