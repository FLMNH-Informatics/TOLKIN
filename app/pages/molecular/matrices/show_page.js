//= require <page>
//= require <widgets/matrices/datagrid>
//= require <widgets/molecular/matrices/user_panel>
//= require <molecular/matrix>
//= require <matrices/version_verifier>
//= require <matrices/row_loader>
//= require <molecular/sequences/sequence_exporting>


Module('Molecular.Matrices', function() {
  JooseClass('ShowPage', {
    isa: Page,
    does: [ VersionVerifier, RowLoader, SequenceExporting ],
    has: {
      canRender: { is: 'ro', init: false },
      widgets:   { is: 'ro', lazy: true, init: function () { return $WSet({
        userPanel: new Molecular.Matrices.UserPanel({ parent: this.frame().viewport(), context: this.context() }),
        datagrid:  new Matrices.Datagrid({            parent: this.frame(),
                                                      type: 'molecular'
        })
      }, this)}},
      records: {is: 'ro', lazy: true, init: function () { return($Records({
        matrixInfo: new Molecular.Matrix({
          id: this.context().params().id,
          context: this.frame().context()
        })
      }, this))}}
    },
    after: {
      initialize: function() {
        params['mol_matrix_id'] = params['id'];
        params['matrix_id'] = params['id'];
      }
    },
    methods: {
      msgNoCells: function (){ this.notifier().warn('You must select some cells to align/export.')},

      onClick: function (event) {
        var me = this
          , wndw = this.frame().viewport().widgets().get('window');

        Event.delegate({
          '#edit_matrix': function(event){ me.matrixInfo().doIfLastVersion(function(){wndw.loadPage('edit_project_molecular_matrix_path')}, me);},

          '#create_alignment': function () {
            me.matrixInfo().doIfNotProcessing(function(){
              var ids = $$('input[type="checkbox"][data-cell-id]:checked').inject('', function (memo,chk){return chk.readAttribute('data-cell-id') + ',' + memo;});
              if (ids == ""){
                me.msgNoCells();
              }else{
                me.createAlignment({cell_ids: ids});
              }
            }, me)
          },

          '#autofill': function () {
            if (confirm("Autofilling very large matrices may take a couple minutes.  Continue?")){
              me.matrixInfo().doIfLastVersion( function () {
                wndw.loadPage('show_autofill_matrix_project_molecular_matrix_path')
              }, me);
            }
          },

          '#export_selected_seqs': function () {
            me.matrixInfo().doIfNotProcessing(function(){
              var ids = $$('input[type="checkbox"][data-cell-id]:checked').inject('', function (memo,chk){return chk.readAttribute('data-cell-id') + ',' + memo;});
              if (ids == ""){
                me.msgNoCells();
              }else{
                me.exportSelectedSeqs({cell_ids: ids});
              }
            }, me);
          },

          '.bt' : function () { //click on a cell
            if (this.widgets()._initial.datagrid._exportModeOn == false){
              var lName = event.element().localName;
              if (lName != 'a' && lName != 'img') {
                event.stop();
                var clickedCell = (event.element().localName == 'td') ? event.element() : event.element().up('td');
                if (clickedCell.hasClassName('bt')){
                  var splitId   = clickedCell.readAttribute('id').split('_')
                    , otuId     = splitId[1]
                    , markerId  = splitId[2];
                  if (clickedCell.hasAttribute('data-cell-id')){
                    if (me.matrixInfo().is('loaded')){
                      var cellId = clickedCell.readAttribute('data-cell-id')
                        , pathName = me.matrixInfo().isLastVersion() && me.iMode()._value == 'edit' && me.matrixInfo().isEditable() ? 'show_cell_project_molecular_matrix_cell_path' : "show_cell_info_project_molecular_matrix_cell_path";
                      wndw.loadPage(pathName, { id: cellId, matrix_id: params['matrix_id'] });
                    }
                  }
                  else {
                    me.matrixInfo().doIfNotProcessing( function(){
                      me.matrixInfo().doIfLastVersion( function(){
                        wndw.loadPage('new_project_molecular_matrix_cell_path', {matrix_id: params['matrix_id'], extraParams: '?otuId='+otuId+'&markerId='+markerId});
                      }, me)
                    }, me)
                  }
                }
              }
            }
          }
        }).call(this, event)
      }
    }
  })
});