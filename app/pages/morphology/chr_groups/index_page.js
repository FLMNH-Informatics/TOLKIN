//= require <page>
//= require <morphology/chr_groups/catalog>
//= require <morphology/chr_group>

JooseModule('Morphology.ChrGroups', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//      records: { is: 'ro', lazy: true, init: function () { return $RSet({
//        chrGroups: Morphology.ChrGroup.collection({context: this.frame().context()})
//      }, this) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        catalog: new Morphology.ChrGroups.Catalog({
          parent: this.frame(),
          collection: Morphology.ChrGroup.collection({context: this.frame().context()})
        })
      }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'filters/_form',
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry'
//        'collections/show',
//        'morphology/chr_groups/catalogs/_action_panel'
      ], this) } }
    }
  });
});
