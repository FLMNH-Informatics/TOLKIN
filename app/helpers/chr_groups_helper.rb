module ChrGroupsHelper
  def chr_groups_catalog
    Morphology::ChrGroups::Catalog.new({
      collection: @chr_groups,
      context: self,
      parent: content_frame
    }).render_to_string
  end
end
