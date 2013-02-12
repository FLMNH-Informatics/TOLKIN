//= require "publication_title_auto_text_field"

JooseModule('Library.Citations', function () {
  JooseClass('SeriesTitleAutoTextField', {
    isa: Library.Citations.PublicationTitleAutoTextField,
    has: {
      method:        { is: 'ro', init: 'series_title' }
    }
  })
});
