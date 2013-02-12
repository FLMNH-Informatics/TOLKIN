//= require <templates/auto_text_field>

JooseModule('Morphology.Matrices', function () {
  JooseClass('MatrixNameFromAutoTextField', {
    isa: Templates.AutoTextField,
    has: {
      object:         { is: 'ro', init: 'matrix' },
      method:         { is: 'ro', init: 'name' },
      collectionURI:  { is: 'ro', init: 'project_morphology_matrices_path' },
      valueMethod:    { is: 'ro', init: 'name' },
      textMethod:     { is: 'ro', init: 'name' },
      searchMethod:   { is: 'ro', init: 'name' },
      width:          { is: 'ro', init: 350 },
      objectName:     { is: 'ro', init: 'matrix' },
      options:        { is: 'ro', init: function() { return ({
        parameters:   { select: 'id, name' }
      })}}
    }
  })
})