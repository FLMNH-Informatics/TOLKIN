//= require <templates/combo_box>

JooseModule('Collections', function () {
  JooseClass('TaxonComboBox', {
    isa: Templates.ComboBox,
    has: {
      method:        { is: 'ro', init: 'taxon' },
      collectionURI: { is: 'ro', init: function () { return Route.forPathname('project_taxa_path') } },
      valueMethod:   { is: 'ro', init: 'taxon_id' },
      textMethod:    { is: 'ro', init: 'label' },
      searchMethod:  { is: 'ro', init: 'name' },
      width:         { is: 'ro', init: 475 },
      options:       { is: 'ro', init: function () { return({
            parameters: {
              select: 'taxon_id, name, label, css_class, namestatus_id',
              joins: 'namestatus',
              limit: '100',
              order: 'name'
            }}) }}
    }
  })
});
