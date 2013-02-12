//= require <page>
//= require <html_loader>
//= requrie <morphology/matrix>
//= require <morphology/matrices/matrix_name_auto_text_field>
//= require <morphology/matrices/matrix_name_from_auto_text_field>

JooseModule('Morphology.Matrices', function () {
  JooseClass('ShowDesignateSubmatrixPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 500 },
      width:          { is: 'ro', init: 500 },
      savable:        { is: 'ro', init: 'true' },
      saveButtonText:       { is: 'ro', init: 'Designate' },
      title:          { is: 'ro', init: 'Designate Submatrix'},
      records:        { is: 'ro', lazy: true, init: function () { return $Records({
            matrix: new Morphology.Matrix({ context: this.context(), data: {} })
      }, this)} },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
            pathname: 'show_designate_submatrix_project_morphology_matrices_path'
      }, this )} },
      widgets:        { is: 'ro', init: function () { return $Widgets({
            matrixNameField: new Morphology.Matrices.MatrixNameAutoTextField({
              object: this.record('matrix'),
              parent: this.frame()
            }),
            matrixNameFromField: new Morphology.Matrices.MatrixNameFromAutoTextField({
              object: this.record('matrix'),
              parent: this.frame()
            })
      }, this )} }
    },
    methods: {
      onClick: function (event) {
        Event.delegate({
          'input[type="button"][value="Designate"]': function (event) {
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
          , parent_matrix = $('from_matrix').down('input').readAttribute('value')
          , submatrix = $('with_matrix').down('input').readAttribute('value');
        if (parent_matrix != null && submatrix != null) {
          this.notifier().working('Designating submatrix...')
          form.request({
            requestHeaders: ["Accept", "application/json"],
            parameters: { parent_matrix: parent_matrix, submatrix: submatrix},
            onSuccess: function (transport) {
              me.notifier().success('Submatrix Designated')
              window.location.reload()
				//maybe respond here with json and fire a recordUpdated
            }})
        }
        else{ this.notifier().error('You must select two matrices.')}
      }
//	  request: function (form) {
//        var me = this
//        // these auto name text fields have two inputs,
//        // the first is the hidden which gets populated by javascript, we prefer that,
//        // if not available, the second is the user input
//        parent_matrix = $('from_matrix').down('input').readAttribute('value') || $('from_matrix').descendants()[6].value
//        submatrix = $('with_matrix').down('input').readAttribute('value') || $('with_matrix').descendants()[6].value
//
//        if (parent_matrix != null && submatrix != null) {
//          this.notifier().working('Designating submatrix...')
//          form.request({
//            requestHeaders: {Accept: "application/json"},
//            parameters: { parent_matrix: parent_matrix, submatrix: submatrix},
//            onSuccess: function (transport) {
//              if (transport.responseJSON){
//
//               var message = transport.responseJSON.message
//                if (message.charAt(0) == "S"){
//                  Morphology.Matrix.fire('recordUpdated', { id: me.params().id })
//                  me.notifier().success(message)
//                  me.frame().close()
//               }
//                else{ me.notifier().error(message) }
//              }
//            }})
//        }
//        else{ me.notifier().error('You must select two matrices.')}
//      }
    }
  })
})