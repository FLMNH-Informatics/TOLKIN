//= require <page>
//= require <widgets/taxa/catalog>
//= require <taxon>

Module('Taxa', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: 'true', init: function () { return $Widgets({
         taxaCatalog:
            new Taxa.Catalog({
              parent: this.frame(),
              collection: Taxon.collection({context: this.frame().context()}),
              context: this.frame().context() }) }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form',
        'widgets/_combo_box',
        'layouts/window',
        'shared/_generic_dialog',
        'shared/_yes_no_dialog',
//        'taxa/catalogs/_action_panel',
        'taxa/show',
        'taxa/_node',
        'taxa/_taxon_details'
      ], this) }}}
  })
});

