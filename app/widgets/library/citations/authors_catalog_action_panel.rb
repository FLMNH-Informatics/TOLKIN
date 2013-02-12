class Library::Citations::AuthorsCatalogActionPanel < Templates::ActionPanel

  def initialize options
    @buttons = {}
    super
  end

  def to_s
    render partial: 'library/citations/authors_catalog_action_panel'
  end
end
