class Chromosome::Probes::Catalog < Templates::Catalog

  def initialize options
    options = {
      columns: [ 
        { attribute: 'value',       width: 120 },
        { attribute: 'scaffold_id', width: 120 },
        { attribute: 'chromosome',  width: 150 },
        { attribute: 'genome_builder_super_scaffold',  width: 170 },
        { attribute: 'probe_type',  width: 100 }
      ],
      data_id: 'id'
    }.merge!(options)
    widgets({
      action_panel: { init: ->{ Chromosome::Probes::Catalogs::ActionPanel.new({ parent: self }) }},
    })
    super
  end
end