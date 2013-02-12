//= require <page>
////= require <molecular/primers/user_panel>
//= require <molecular/primers/catalog>
//= require <molecular/primer>

JooseModule('Molecular.Primers', function () {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
//             userPanel: new Widgets.Molecular.Primers.UserPanel({
//               parent: this.frame().viewport()
//             }),
        catalog: new Molecular.Primers.Catalog({
          parent: this.frame(),
          collection: Molecular.Primer.collection({ context: this.context() })
        })
      }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'//,
//         'molecular/primers/_new_primer_window',
//         'molecular/primers/_primer_details'
      ], this) } }
    }
  })
})

