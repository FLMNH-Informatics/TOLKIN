class ImageAlbums::Catalog < Templates::Catalog
 def initialize options
    options = {
      columns: [
        { attribute: 'attachment_file_name',      width: 250 },
        { attribute: 'created_at',      width: 250 },
      ],
      data_id: 'id'
    }.merge!(options)
    widgets({
      action_panel: { init: ->{ ImageAlbums::Catalogs::ActionPanel.new({ parent: self }) }},
    })
    super
  end
end