class Molecular::Insd::Seqs::Catalog < Templates::Catalog
  def initialize options
    options = {
      columns: [  { attribute: "organism",    width: 150 },
                  { attribute: "markers_fulltext", label: "Markers",     width: 110 },
                  { attribute: "locus",       width: 70 },
                  { attribute: "definition",  width: 350 },
                  { attribute: "sequence",    width: 350 }  ],
      data_id: 'pk'
    }.merge!(options)
    widgets({
      action_panel: { init: ->{ Molecular::Insd::Seqs::Catalogs::ActionPanel.new({ parent: self }) }},
    })
    super
  end
end