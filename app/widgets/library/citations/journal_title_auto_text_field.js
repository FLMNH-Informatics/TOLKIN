//= require "publication_title_auto_text_field"
//= require <library/publication>

JooseModule('Library.Citations', function () {
  JooseClass('JournalTitleAutoTextField', {
    isa: Library.Citations.PublicationTitleAutoTextField,
    has: {
      method:        { is: 'ro', init: 'journal_title' },
      where:         { is: 'ro', init: function () {
        return SyncRecord.attr('publication_type').eq('journal')
      }}
    }
  })
});