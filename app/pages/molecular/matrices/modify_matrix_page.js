//= require <page>
//= require <widgets/molecular/matrices/user_panel>
//= require <matrices/version_verifier>
//= require <matrices/modify_matrix>


JooseModule('Molecular.Matrices', function () {
  JooseClass('ModifyMatrixPage', {
    isa: Page,
    does: [VersionVerifier, ModifyMatrix],  //most functions/methods are in lib/matrices/modify/matrix
    has: {
      canRender: {is: 'ro', init: false},
      widgets:   {is: 'ro', lazy: true, init: function(){ return $WSet({
        userPanel: new Molecular.Matrices.UserPanel({ parent: this.frame().viewport(), context: this.context() })
      }, this)}},
      records: {is: 'ro', lazy: true, init: function () { return($Records({
        matrixInfo: new Molecular.Matrix({id: this.context().params().id, context: this.frame().context()})
      }, this))}}
    },
    after: {
      initialize: function () {
        params['mol_matrix_id'] = params['id'];
        params['matrix_id']     = params['id'];
      }
    }
  })
})