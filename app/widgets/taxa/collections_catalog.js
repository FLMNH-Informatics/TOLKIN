//= require <templates/catalog>
//= require <collection>

Module('Taxa', function () {
  JooseClass('CollectionsCatalog', {
    isa: Templates.Catalog,
    has: {
      taxon: { is: 'ro', required: true, nullable: false },
      limit: { is: 'ro', init: 10 },
      columns: { init: function () { return [
            { attribute: 'collector', width: 100 },
            { attribute: 'collection_number', width: 100 },
            { attribute: 'country', width: 100 },
            { attribute: 'institution_code', width: 100 }
      ]}},
      frame: { is: 'ro', required: true, nullable: false },
      hasFilterSet: { is: 'ro', init: false },
      collectionClass: { is: 'ro', init: function () { return Collection } },
      collection: { is: 'ro', init: function () {
        return (
          Collection.
            collection({
              context: this.context(),
              initLoader: this.taxon(),
              initLoaderFn: function (atts) {
                return atts.collections
              },
              finderOptions: {
                select: [ 'id', 'taxon_id', 'collector', 'collection_number', 'country', 'institution_code' ],
                conditions: Collection.attribute('taxon_id').eq(this.taxon().id()),
                order: [ 'country', 'collector', 'collection_number' ],
                limit: 10
              }
            })
        )
      } }
    },
    methods: {
      onRowClick: function(event) {
       this.frame().loadPage('project_collection_path', { id: event.element().up('tr[data-id]').readAttribute('data-id') })
//        var me = this
//        var page = this.page()
//
//        new Ajax.Request(me.routes().pathFor('project_collection_path', { id: event.element().up('tr[data-id]').readAttribute('data-id') }), {
//          //parameters:  { id: event.element().up('tr[data-id]').readAttribute('data-id') },
//          method: 'get',
//          requestHeaders: {
//            Accept: 'application/json'
//          },
//          onSuccess: function (transport) {
//            page._rendered = transport.responseText
//
//            var temp = me.frame().templates().get('collections/show')
//            me.setState('loaded')
//          }
//        });
//        if(this._inARow(event.element())) {
//        function loadCollectionWindow () {
//          collectionWindow.collection().load({
//            onSuccess: function () {
//              collectionWindow.render();
//              collectionWindow.display();
//              collectionWindow.show();
//              collectionWindow.toFront();
//            }.bind(collectionWindow)
//          })
//        }
//        var collectionId = event.element().up('tr[data-id]').readAttribute('data-id');
//        var collection = new Collection({ id: collectionId, context: this.context() });
//        var collectionWindow = new Collections.Window({ parent: this.viewport(), context: this.context(), collection: collection });
//        this.viewport().widgets().add(collectionWindow);
//        if (this.template('collections/_annotations_catalog_action_panel') ) {
//          loadCollectionWindow()
//        } else {
//          this.templates().load('collections/_annotations_catalog_action_panel', {
//            onSuccess: function () {
//              loadCollectionWindow()
//            }
//          })
//        }
      }
    }
  })
});
