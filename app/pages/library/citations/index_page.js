//= require <page>
//= require <library/citation>
//= require <library/citations/catalog>

JooseModule('Library.Citations', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//      records: { is: 'ro', lazy:true, init: function () { return $Records({
//        citations:
//
//      },this) }},
      widgets: {is: 'ro', lazy: true,  init: function () { return $Widgets({
        citationCatalog:
          new Library.Citations.Catalog({
              parent: this.frame(),
              collection: Library.Citation.collection({context: this.frame().context()}),
              context: this.frame().context() }) },this) } },
      templates: { is: 'ro', lazy:true, init:function() { return $Templates([
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'//,
//        'library/citations/catalogs/_action_panel'//,
        //'library/citations/_authors_catalog_action_panel'
      ], this) } }
    }
  })
});
