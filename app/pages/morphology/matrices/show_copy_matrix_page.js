//= require <page>
//= require <html_loader>
//= require <matrices/matrix_copier>

JooseModule('Morphology.Matrices', function () {
  JooseClass('ShowCopyMatrixPage', {
    isa: Page,
    does: MatrixCopier,
    has: {
      canRender:      { is: 'ro', init: true },
      title:          { is: 'ro', init: 'Morphology : Matrix - Copy' },
      width:          { is: 'ro', init: 475 },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: "Save" },
      height:         { is: 'ro', init: 150 },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_copy_matrix_project_morphology_matrix_path'
      }, this) } },
      matrixName:          { is: 'rw', init: null},
      timelineDescription: { is: 'rw', init: null},
      newTimelineId:       { is: 'rw', init: null}
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"][value="Save"]': function (event) { me.copyMatrix(); }
        }).call(this,event)
      }
    }
  })
})