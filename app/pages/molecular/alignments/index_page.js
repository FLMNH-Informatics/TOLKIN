//= require <page>
//= require <molecular/alignments/catalog>
//= require <molecular/alignments/user_panel>

JooseModule('Molecular.Alignments', function () {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
//          userPanel:  new Molecular.Alignments.UserPanel({ parent: this.frame().viewport() }),
          catalog:    new Molecular.Alignments.Catalog({ parent: this.frame() })  }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
//        'widgets/_combo_box',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form',
        'layouts/window'//,
//        'molecular/alignments/new',
//        'molecular/alignments/show'//,
//        'molecular/alignments/catalogs/_action_panel'
      ], this ) }}
    }
  })
})
