//= require <page>
//= require <html_loader>
//= require <molecular/matrix>

JooseModule('Molecular.Matrix.Cells', function () {
  JooseClass('ShowCellInfoPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      width:          { is: 'ro', init: 420 },
      height:         { is: 'ro', init: 420 },
      title:          { is: 'ro', init: "Matrix: View Cell: Info"},
      savable:        { is: 'ro', init: false },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_cell_info_project_molecular_matrix_cell_path' }, this ) } },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'filters/_form'
      ], this )  } }
    },
    after: {
      onLoad: function () {}
    },
    methods: {
      onClick: function (event) {
        if (event.element().hasClassName('display_sequence')) {
          this.frame().loadPage('project_molecular_sequence_path', { id: event.element().up('tr').dataset.seqId });
        }
      }
    }
  })
})