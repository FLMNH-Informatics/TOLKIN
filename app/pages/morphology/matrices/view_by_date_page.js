//= require <page>
//= require <widgets/matrices/datagrid>
//= require <widgets/morphology/matrices/user_panel>
//= require <morphology/matrix>
//= require <matrices/row_loader>


Module('Morphology.Matrices', function() {
  JooseClass('ViewByDatePage', {
    isa: Page,
    does: RowLoader,
    has: {
      canRender: { is: 'ro', init: false },
      widgets:   { is: 'ro', lazy: true, init: function () { return $WSet({
        userPanel: new Morphology.Matrices.UserPanel({ parent: this.frame().viewport(), context: this.context() }),
        datagrid:  new Matrices.Datagrid({             parent: this.frame(),
                                                       type: 'morphology',
                                                       context: this.frame().context(),
                                                       chrStateDefs: chrStateDefs /**variable that is set on partial _chr_state_tooltips.html.haml **/ })
      }, this)}},
      records: {is: 'ro', lazy: true, init: function () { return($Records({
        matrixInfo: new Morphology.Matrix({id: this.context().params().id, context: this.frame().context()})
      }, this))}},
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
          'layouts/window'
      ], this)}} },
    after: {
      initialize: function() {
        params['morph_matrix_id'] = params['id'];
        params['matrix_id'] = params['id'];
        setTableBodyExpanderWidth();
        setTableScrollObserver();
      }
    },
    methods: {
      matrixInfo: function () {return this.records().get('matrixInfo')},
      showWrongVersionMessage: function () {this.notifier().warning(this.matrixInfo().wrongVersionMessage());},
      onClick: function (event) {
        var me = this
          , wndw = this.frame().viewport().widgets().get('window');
        Event.delegate({
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
                    wndw.loadPage('show_cell_info_project_morphology_matrix_cell_path', { id: cellId, matrix_id: params['matrix_id'] });
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