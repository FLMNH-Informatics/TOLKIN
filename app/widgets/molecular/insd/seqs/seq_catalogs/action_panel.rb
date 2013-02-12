class Molecular::Insd::Seqs::SeqCatalogs::ActionPanel < Templates::ActionPanel
  def initialize options
    options = { buttons: [ { label: 'Add to Cell', img: { src: '/images/small_addnew.gif' } } ] }.merge(options)
    super
    if interact_mode != 'edit'
      @buttons = {}
    end
  end
end