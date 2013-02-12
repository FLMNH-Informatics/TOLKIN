//= require <page>
//= require <widgets/matrices/datagrid>
//= require <widgets/molecular/matrices/user_panel>
//= require <molecular/sequences/sequence_exporting>
//= require <matrices/row_loader>


Module('Molecular.Matrices', function() {
  JooseClass('ViewByDatePage', {
    isa:  Page,
    does: [SequenceExporting, RowLoader],
    has: {
      canRender: { is: 'ro', init: false },
      widgets:   { is: 'ro', lazy: true, init: function () { return $WSet({
        userPanel: new Molecular.Matrices.UserPanel({ parent: this.frame().viewport(), context: this.context() }),
        datagrid:  new Matrices.Datagrid({            parent: this.frame(),
                                                      type: 'molecular' })
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
        setTableBodyExpanderWidth();
        setTableScrollObserver();
      }
    },
    methods: {
      onClick: function (event) {
        var me = this
          , wndw = this.frame().viewport().widgets().get('window');
        Event.delegate({

          '#create_alignment': function () {
            var ids = $$('input[type="checkbox"][data-cell-id]:checked').inject('', function (memo,chk){return chk.readAttribute('data-cell-id') + ',' + memo;});
            me.createAlignment({cell_ids: ids});
          },

          '#export_selected_seqs': function () {
            var ids = $$('input[type="checkbox"][data-cell-id]:checked').inject('', function (memo,chk){return chk.readAttribute('data-cell-id') + ',' + memo;});
            this.exportSelectedSeqs({cell_ids: ids});
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
                    var cellId = clickedCell.readAttribute('data-cell-id');
                    wndw.loadPage('show_cell_info_project_molecular_matrix_cell_path', { id: cellId, matrix_id: params['matrix_id'] });
                  } else {
                    this.notifier().notify('Cell has no information associated with it.')
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