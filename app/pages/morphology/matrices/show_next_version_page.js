//= require <page>
//= require <html_loader>
//= require <morphology/matrix>
//= require <matrices/next_version>

JooseModule('Morphology.Matrices', function () {
  JooseClass('ShowNextVersionPage', {
    isa: Page,
    does: NextVersion,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 150 },
      width:          { is: 'ro', init: 475 },
      title:          { is: 'ro', init: 'Matrix: Next Version' },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is:'ro', init: 'Save' },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_next_version_project_morphology_matrix_path'
      }, this)}},
      matrixName: {is: 'rw', init: null},
      timelineDescription: {is: 'rw', init:null},
      newTimelineId: {is: 'rw', init: null}
    }
  })
})