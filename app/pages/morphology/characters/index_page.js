//= require <page>
//= require <morphology/characters/catalog>

Module('Morphology.Characters', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//      records: { is: 'ro', lazy: true, init: function () { return $RSet({
//        characters:
//
//      }, this) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        catalog:
          new Morphology.Characters.Catalog({
            parent: this.frame() ,
            collection: Morphology.Character.collection({ context : this.frame().context() }),
            context: this.frame().context()  }) }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'filters/_form',
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry'
//        'collections/_window'//,
        /*'morphology/characters/catalogs/_action_panel'*/
      ], this)
       }}
    }
  })
});

