class Library::Citations::SeriesTitleAutoTextField < Library::Citations::PublicationTitleAutoTextField
  def initialize options
    @attribute_path = 'series_title'
    super
  end
end
