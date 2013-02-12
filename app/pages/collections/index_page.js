//= require <page>
//= require <collections/catalog>

Module('Collections', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        catalog:
          new Collections.Catalog({
            parent: this.frame(),
            context: this.frame().context(),
            collection: Collection.collection({ context: this.frame().context() })
          })
      }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
          'filters/_form',
          'forms/_date_field',
          'layouts/window',
          'widgets/_catalog',
          'widgets/_combo_box',
          'widgets/catalogs/_entry',
          'collections/show'//,
          //'collections/catalogs/_action_panel'
        ], this) } 
      }
    }
  })
})
