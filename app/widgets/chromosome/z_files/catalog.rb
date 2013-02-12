class Chromosome::ZFiles::Catalog < Templates::Catalog
  def initialize options
    options = {
      columns: [ 
        { attribute: 'zvi_file_name', label: 'ZVI filename',      width: 200 },
        { attribute: 'caption',      width: 230 },
      ],
      data_id: 'id'
    }.merge!(options)
    widgets({
      action_panel: { init: ->{ Chromosome::ZFiles::Catalogs::ActionPanel.new({ parent: self }) }},
    })
    super
  end
end