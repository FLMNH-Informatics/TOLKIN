//= require <templates/auto_complete_field>

JooseModule('Molecular.Primers', function () {
  JooseClass('TaxonAutoCompleteField', {
    isa: Templates.AutoCompleteField,
    has: {
      primer: { is: 'ro', required: true, nullable: false },
      object: { is: 'ro', init: function () { return this.primer() } },
      method:        { is: 'ro', init: 'taxon' },
      valueMethod:   { is: 'ro', init: 'rtid' },
      textMethod:    { is: 'ro', init: 'name' },
      width:         { is: 'ro', init: 275 },
      collection: { is: 'ro', init: function () { return (
        Taxon.
          collection({ context: this.context() }).
          select('rtid', 'name')
      ) } }
    }
  })
})
