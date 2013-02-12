//= require <templates/combo_box>

JooseModule('Taxa', function () {
  JooseClass('ChooseTaxonComboBox', {
    isa: Templates.ComboBox,
    has: {
      taxon:   { is: 'ro', required: true, nullable: false },
      object:  { is: 'ro', init: function () { return this.taxon() }},
      context: { is: 'ro', required: true, nullable: false },
      method:  { is: 'ro', init: 'chosen' },
      collectionURI: { is: 'ro', init: function () { return Route.forPathname('project_taxa_path') } },
      valueMethod:   { is: 'ro', init: 'id' },
      textMethod:    { is: 'ro', init: 'label' },
      options: { is: 'ro', init: function () { return {
            parameters: {
              include:    'namestatus',
              only:       'id,name,author,year,label,namestatus_id'
      }}}}
    }
  })
});