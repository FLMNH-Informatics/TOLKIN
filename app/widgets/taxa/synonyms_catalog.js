//= require <templates/catalog>
//= require <taxon>

Module('Taxa', function () {
  JooseClass('SynonymsCatalog', {
    isa: Templates.Catalog,
    has: {
      taxon:          { is: 'ro', required: true, nullable: false },
      limit:          { is: 'ro', init: 10 },
      collectionName: { init: 'synonyms' },
      columns:        { init: function () { return [
        { attribute: "label",                       label: 'Name',       width: 500, cssClass: 'css_class' },
        { attribute: "namestatus.namestatus.status", label: 'Namestatus', width: 100, cssClass: 'css_class' }
      ] }},
      dataId: { is: 'ro', init: 'taxon_id' },
      frame: { is: 'ro', required: true, nullable: false },
      hasFilterSet: { is: 'ro', init: false },
      hasContentsForm: { is: 'ro', init: false },
      collection: { is: 'ro', init: function () {
        return (
          Taxon.collection({
            context: this.context(),
            initLoader: this.taxon(),
            initLoaderFn: function (atts) {
              return atts.synonyms
            },
            finderOptions: {
              select: [ 'taxon_id','id', 'accepted_name_id', 'label', 'css_class' ],
              conditions: SyncRecord.attr('accepted_name_id').eq(this.taxon().id()),
              include: { namestatus: { select: [ 'id', 'status' ] } },
              order: 'publication_date',
              limit: 10
            }
          })
        )
      }}
    },
    methods: {
      onRowClick: function(event) {
        var id = event.element().up('.row').readAttribute('data-id')
        this.frame().loadPage('project_taxon_path', { id: id })
      }
    }
  })
});
