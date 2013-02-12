//= require <page>
//= require <otu_groups/catalog>
//= require <otu_group>

JooseModule('OtuGroups', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//      records: { is: 'ro', lazy: true, init: function () { return $RSet({
//        otuGroups: OtuGroup.collection({context: this.frame().context()})
//      }, this) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        otuGroupCatalog:   
          new OtuGroups.Catalog({
            parent:     this.frame(),
            collection: OtuGroup.collection({context: this.frame().context()}),
            context:    this.frame().context() }) }, this) }},
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'filters/_form',
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry'//,
//        'otu_groups/catalogs/_action_panel'
      ], this) } } } }) });
