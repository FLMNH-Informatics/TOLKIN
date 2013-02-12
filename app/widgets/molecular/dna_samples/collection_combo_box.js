//= require <templates/combo_box>

JooseModule('Molecular.DnaSamples', function () {
  JooseClass('CollectionComboBox', {
    isa: Templates.ComboBox,
    has: {
      object:  { is: 'ro', required: true, nullable: false },
      method: { is: 'ro', init: 'collection' },
      collectionURI: { is: 'ro', init: Route.forPathname('project_collections_path')},//'/projects/'+params['project_id']+'/collections' },
      valueMethod: { is: 'ro', init: 'id' },
      textMethod: { is: 'ro', init: 'label' },
      searchMethod: { is: 'ro', init: 'collector' },
      options: { is: 'ro', init: function () { return {
            requestHeaders: { Accept: 'text/javascript' },
            parameters: {
              select: 'id,label,collector,collection_number',
              order: 'collector, collection_number',
              include: '',
              limit: ''
            }} }},
      tagName: { init: 'dna_sample[collection_id]' }
    }
  })
});
