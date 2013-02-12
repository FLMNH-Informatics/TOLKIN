//= require <templates/auto_text_field>

JooseModule('Library.Citations', function () {
  JooseClass('PublisherNameAutoTextField', {
    isa: Templates.AutoTextField,
    has: {
      object:        { is: 'ro', init: 'citation' },
      method:        { is: 'ro', init: 'publisher' },
      collectionURI: { is: 'ro', init: 'project_library_publishers_path' },
      valueMethod:   { is: 'ro', init: 'id' },
      textMethod:    { is: 'ro', init: 'name' },
      searchMethod:  { is: 'ro', init: 'name' },
      width:         { is: 'ro', init: 275 },
      objectName:    { is: 'ro', init: 'citation' },
      options:       { is: 'ro', init: function () { return ({
        parameters: {
          select: 'id, name'
        }
      }) }}
    }
  })
});
