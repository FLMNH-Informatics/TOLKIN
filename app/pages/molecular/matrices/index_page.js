//= require <page>
//= require <molecular/matrices/catalog>
//= require <molecular/matrix_view>

JooseModule('Molecular.Matrices', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        catalog:
          new Molecular.Matrices.Catalog({
            parent: this.frame(),
            collection: Molecular.MatrixView.collection({ context: this.context() })
          })
      }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
//        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry'//,
        //'molecular/matrices/catalogs/_action_panel'
      ], this ) } }
    }
  })
});
