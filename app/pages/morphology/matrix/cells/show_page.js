//= require <page>
//= require <html_loader>
//= require <morphology/matrix/cell/morph_cell_controls>

Module('Morphology.Matrix.Cells', function () {
  JooseClass('ShowPage', {
    isa: Page,
    does: MorphCellControls,
    has: {
      width:          { is: 'ro', init: 810 },
      height:         { is: 'ro', init: 350 },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Save' },
      canRender:      { is: 'ro', init: true },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'project_morphology_matrix_cell_path'
      }, this )}},
      title:        { is: 'ro', init: 'Morphology Matrix Cell: Show'}
    }
  })
})