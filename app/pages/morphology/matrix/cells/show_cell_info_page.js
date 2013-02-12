//= require <page>
//= require <html_loader>
//= require <morphology/matrix/cell/morph_cell_controls>

Module('Morphology.Matrix.Cells', function () {
  JooseClass('ShowCellInfoPage', {
    isa: Page,
    does: MorphCellControls,
    has: {
      width:     { is: 'ro', init: 810 },
      height:    { is: 'ro', init: 400 },
      savable:   { is: 'ro', init: false },
      canRender: { is: 'ro', init: true },
      htmlLoader:{ is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_cell_info_project_morphology_matrix_cell_path'
      }, this )}},
      title: { is: 'ro', init: 'Morphology Matrix Cell: Info'}
    }
  })
})