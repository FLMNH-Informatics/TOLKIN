//= require <page>
//= require <library/publication>
//= require <widgets/library/publications/catalog>

JooseModule('Views.Library.Publications', function() {
  JooseClass('Index', {
    isa: Page,
    has: {
      records: { is: 'ro', lazy: true, init: function () { return $RSet({
        publications:
          Library.Publication
            .collection({context: this.frame().context()})
      }, this) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        publicationCatalog:
          new Widgets.Library.Publications.Catalog({
            parent: this.frame(),
            collection: this.records().get('publications'),
            context: this.frame().context() }) },this) } },
      templates: { is: 'ro', lazy:true, init:function() { return $TSet([
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form',
        'library/publications/catalogs/_action_panel'
      ], this) } }
    }
  })
});
