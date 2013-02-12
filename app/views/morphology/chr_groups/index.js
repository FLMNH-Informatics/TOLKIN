//= require <page>
//= require <widgets/morphology/chr_groups/catalog>
//= require <morphology/chr_group>

JooseModule('Views.Morphology.ChrGroups', function() {
  JooseClass('Index', {
    isa: Page,
    has: {
      records: { is: 'ro', lazy: true, init: function () { return $RSet({
        chrGroups:
          Morphology.ChrGroup
            .collection({context: this.frame().context()})
      }, this) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        catalog:
          new Widgets.Morphology.ChrGroups.Catalog( { 
            parent: this.frame() ,
            collection: this.records().get('chrGroups'),
            context: this.frame().context()  }) }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'filters/_form',
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'collections/show',
        'morphology/chr_groups/catalogs/_action_panel'], this) } }
    }
  });
});
