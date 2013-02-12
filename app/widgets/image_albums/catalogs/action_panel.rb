class ImageAlbums::Catalogs::ActionPanel < Templates::ActionPanel
  def initialize options
    options = { buttons: [ { label: 'Add', img: { src: '/images/small_addnew.gif' } },
                           { label: 'Delete', img: { src: '/images/small_cross.png' } }
    ]}.merge(options)
    super
    if interact_mode != 'edit'
      @buttons = {}
    end
  end
end