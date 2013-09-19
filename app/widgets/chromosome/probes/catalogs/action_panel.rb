class Chromosome::Probes::Catalogs::ActionPanel < Templates::ActionPanel
  def initialize options
    options = { buttons: [ { label: 'Create', img: { src: '/images/small_addnew.gif' } },
                           { label: 'Delete', img: { src: '/images/small_cross.png' } },
                           { label: 'Bulk Upload', img: { src: "/images/small_addnew.gif" }, imode: 'edit' }

#                           { label: 'Align', img: { src: '/images/addnew.gif'} }
                         ]}.merge(options)
    super
    if interact_mode != 'edit'
      @buttons = {}
    end
  end
end
