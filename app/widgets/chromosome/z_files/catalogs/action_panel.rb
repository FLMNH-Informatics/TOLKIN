class Chromosome::ZFiles::Catalogs::ActionPanel < Templates::ActionPanel
  def initialize options
    options = { buttons: [
                           { label: 'Upload', img: { src: '/images/small_addnew.gif' } },
                           { label: 'Download', img: { src: '/images/small_arrow.png' } },
                           { label: 'Delete', img: { src: '/images/small_cross.png'} }
                         ]}.merge(options)
    super
    if interact_mode != 'edit'
      @buttons = {}
    end
  end
end
