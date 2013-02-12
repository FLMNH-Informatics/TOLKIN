//= require <templates/auto_complete_field>
//= require <molecular/purification_method>

JooseModule('Molecular.Primers', function () {
  JooseClass('PurificationMethodAutoCompleteField', {
    isa: Templates.AutoCompleteField,
    has: {
      primer: { is: 'ro', required: true, nullable: false },
      object: { is: 'ro', init: function () { return this.primer() } },
      method:        { is: 'ro', init: 'purification_method' },
      valueMethod:   { is: 'ro', init: 'id' },
      textMethod:    { is: 'ro', init: 'name' },
      width:         { is: 'ro', init: 275 },
      collection: { is: 'ro', init: function () { return (
        Molecular.PurificationMethod.
          collection({ context: this.context() }).
          select('id', 'name')
      ) } }
    }
  })
})
