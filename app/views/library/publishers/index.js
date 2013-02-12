//= require <page>
//= require <library/publisher>
//= require <widgets/library/publishers/catalog>

JooseModule('Views.Library.Publishers', function() {
  JooseClass('Index', {
    isa: Page,
    has: {
      records: { is: 'ro', lazy: true, init: function () { return $RSet({
            publishers:
              Library.Publisher
                .collection({context: this.frame().context()})
      }, this) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
          publisherCatalog:
            new Widgets.Library.Publishers.Catalog({
              parent: this.frame(),
              collection: this.records().get('publishers'),
              context: this.frame().context() }) },this) } },
           templates: { is: 'ro', lazy:true, init:function() { return $TSet([
          'layouts/window',
          'widgets/_catalog',
          'widgets/catalogs/_entry',
          'library/publishers/catalogs/_action_panel'], this) } } } }) });
