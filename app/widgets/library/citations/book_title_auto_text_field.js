//= require "publication_title_auto_text_field"
//= require <library/publication>

JooseModule('Library.Citations', function () {
  JooseClass('BookTitleAutoTextField', {
    isa: Library.Citations.PublicationTitleAutoTextField,
    has: {
      object:        { is: 'ro', init: 'citation' },
      method:        { is: 'ro', init: 'book_title' },
      where:         { is: 'ro', init: function () {
        return SyncRecord.attr('publication_type').eq('book')
      }}
    }
  })
});
