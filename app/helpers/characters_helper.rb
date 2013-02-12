require 'morphology/characters/catalog'
module CharactersHelper
  def characters_catalog
    Morphology::Characters::Catalog.new(
      collection: @characters,
      context: self,
      parent: content_frame
    ).render_to_string
  end
end
