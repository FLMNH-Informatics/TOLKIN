//= require <templates/combo_box>
//= require <sync_record>

JooseModule('Taxa', function () {
  JooseClass('AcceptedNameComboBox', {
    isa: Templates.ComboBox,
    has: {
      taxon:   { is: 'ro', required: true, nullable: false },
      object:  { is: 'ro', init: function () { return this.taxon() }},
//      context: { is: 'ro', required: true, nullable: false },
      method:  { is: 'ro', init: 'accepted_name' },
      width:   { is: 'ro', init: 400 },
      collectionURI: { is: 'ro', init: function () { return Route.forPathname('project_taxa_path') } },
      valueMethod:   { is: 'ro', init: 'taxon_id' },
      textMethod:    { is: 'ro', init: 'label' },
      searchMethod:  { is: 'ro', init: 'name' },
      where:   { is: 'ro', init: function () { return SyncRecord.attr('namestatuses.status').eq('accepted_name') } },
      options: { is: 'ro', init: function () { return {
        parameters: {
          joins:      'namestatus',
          include:    'namestatus',
          order:      'name',
          select:     'taxon_id,name,label,namestatus_id',
          limit:      '100'
      }}}}
    }
  })
});