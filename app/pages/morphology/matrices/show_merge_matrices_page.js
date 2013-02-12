//= require <page>
//= require <html_loader>
//= requrie <morphology/matrix>
//= require <morphology/matrices/matrix_name_auto_text_field>
//= require <morphology/matrices/matrix_name_from_auto_text_field>

JooseModule('Morphology.Matrices', function () {
  JooseClass('ShowMergeMatricesPage', {
    isa: Page,
    has: {
      canRender:        { is: 'ro', init: true },
      height:           { is: 'ro', init: 500 },
      width:            { is: 'ro', init: 600 },
      title:            { is: 'ro', init: 'Merge Matrices'},
      records:          { is: 'ro', lazy: true, init: function () { return $Records({
            matrix: new Morphology.Matrix({ context: this.context(), data: {} })
      }, this)}},
      savable:          { is: 'ro', init: true },
      saveButtonText:   { is: 'ro', init: 'Merge'},
      htmlLoader:       { is: 'ro', init: function () { return $HtmlLoader({
            pathname: 'show_merge_matrices_project_morphology_matrices_path'
      }, this )}},
      widgets:          { is: 'ro', init: function () { return $Widgets({
            matrixNameField: new Morphology.Matrices.MatrixNameAutoTextField({
              object: this.record('matrix'),
              parent: this.frame()
            }),
            matrixNameFromField: new Morphology.Matrices.MatrixNameFromAutoTextField({
              object: this.record('matrix'),
              parent: this.frame()
            })
      }, this )}}

    },
    methods: {
      onClick: function (event) {
        Event.delegate({
          'input[type="button"][value="Merge"]': function (event) {
            this.request(this.frame().element().down('form'))
          }
        }).call(this, event)
      },
      onSubmit: function (event) {
        event.stop()
        this.request(event.element())
      },
      request: function (form) {
        var me = this
        from_matrix = $('from_matrix').down('input').readAttribute('value')
        to_matrix = $('with_matrix').down('input').readAttribute('value')
        if (from_matrix != null && to_matrix != null && $('to_matrix_version_select').value != null && $('from_matrix_version_select').value != null){
          this.notifier().working('Merging matrices')
          form.request({
            requestHeaders: ["Accept", "application/json"],
            parameters: { from_name: from_matrix, to_name: to_matrix },
            onSuccess: function (transport) {
              me.notifier().success('Matrices merged')
              me.frame().close()
              window.location = "/projects/" + params['project_id'] + "/morphology/matrices/" + transport.responseJSON
            }
          })
        }
        else { me.notifier().error('You must select two matrices and choose two versions.')}
      }
  }})
})