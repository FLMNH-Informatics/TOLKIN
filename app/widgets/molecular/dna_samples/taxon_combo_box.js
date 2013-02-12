//= require <templates/combo_box>
//= require <sync_record>

JooseModule('Molecular.DnaSamples', function () {
  JooseClass('TaxonComboBox', {
    isa: Templates.ComboBox,
    has: {
      object:  { is: 'ro', required: true, nullable: false },
      method:  { is: 'ro', init: 'taxon' },
      collectionURI: { is: 'ro', init: function () { return Route.forPathname('project_taxa_path') } },
      valueMethod:   { is: 'ro', init: 'taxon_id' },
      textMethod:    { is: 'ro', init: 'label' },
      searchMethod:  { is: 'ro', init: 'name' },
      width:         { is: 'ro', init: 325 },
      options: { is: 'ro', init: function () { return {
        parameters: {
          joins:      'namestatus',
          include:    'namestatus',
          order:      'name',
          select:     'taxon_id,name,label,namestatus_id',
//          select:     'taxon_id,name,label',  //previously some taxa records had null namestatus id but fixed with migration 20120910161627
          limit:      '100'
      }}}},
      tagName: { init: 'dna_sample' }
    }
  })
});
