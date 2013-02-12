//= require <templates/auto_text_field>

JooseModule('Morphology.Matrices', function () {
  JooseClass('OtuNameAutoTextField', {
    isa: Templates.AutoTextField,
    has: {
      object:         { is: 'ro', init: 'otu' },
      method:         { is: 'ro', init: 'name' },
      collectionURI:  { is: 'ro', init: 'project_otus_path' },
      valueMethod:    { is: 'ro', init: 'name' },
      textMethod:     { is: 'ro', init: 'name' },
      searchMethod:   { is: 'ro', init: 'name' },
      width:          { is: 'ro', init: 275 },
      objectName:     { is: 'ro', init: 'otu' },
      options:        { is: 'ro', init: function() { return ({
        parameters:   { select: 'id, name' }
      })}}
    }
  })
})