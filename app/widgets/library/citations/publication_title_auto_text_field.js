//= require <templates/auto_text_field>

JooseModule('Library.Citations', function () {
  JooseClass('PublicationTitleAutoTextField', {
    isa: Templates.AutoTextField,
    has: {
      object:        { is: 'ro', init: 'citation' },
      method:        { is: 'ro', init: 'publication_title' },
      collectionURI: { is: 'ro', init: 'project_library_publications_path' },
      valueMethod:   { is: 'ro', init: 'l_publication_id' },
      textMethod:    { is: 'ro', init: 'value' },
      searchMethod:  { is: 'ro', init: 'value' },
      width:         { is: 'ro', init: 275 },
      objectName:    { is: 'ro', init: 'citation' },
      options:       { is: 'ro', init: function () { return ({
        parameters: {
          select: 'l_publication_id, value'
        }
      }) }}
    }
  })
});
