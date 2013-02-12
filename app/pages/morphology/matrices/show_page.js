//= require <page>
//= require <widgets/matrices/datagrid>
//= require <matrices/datagrids/cell>
//= require <morphology/matrix>
//= require <widgets/morphology/matrices/cells/window>
//= require <widgets/morphology/matrices/user_panel>
//= require <matrices/version_verifier>
//= require <matrices/row_loader>



Module('Morphology.Matrices', function() {
  JooseClass('ShowPage', {
    isa: Page,
    does: [ VersionVerifier, RowLoader ],
    has: {
      canRender: { is: 'ro', init: false },
      records: {is: 'ro', lazy: true, init: function () { return($Records({
        matrixInfo: new Morphology.Matrix({id: this.context().params().id, context: this.frame().context()})
      }, this))}},
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
          userPanel: new Morphology.Matrices.UserPanel({  parent: this.frame().viewport(), context: this.context() }),
          datagrid: new Matrices.Datagrid({ parent: this.frame(),
                                            type: 'morphology',
                                            context: this.frame().context(),
                                            chrStateDefs: chrStateDefs /**variable that is set on partial _chr_state_tooltips.html.haml **/
            }) }, this) }
      }
    },
    after: {
      initialize: function() {
        params['morph_matrix_id'] = params['id'];
        params['matrix_id'] = params['id'];
        setTableScrollObserver();
        setTableBodyExpanderWidth();
      }
    },
    methods: {
      onClick: function (event) {
        var me = this
          , wndw = this.frame().viewport().widgets().get('window');
        Event.delegate({
          '#edit_matrix' : function (event) { me.matrixInfo().doIfLastVersion(function (){
              wndw.loadPage('edit_project_morphology_matrix_path')
            }, me);},
          '.bt': function () {//clicked on a cell
            if (this.widgets()._initial.datagrid._quickEditModeOn == false){
              var ids    = event.element().id.split('_')
                , otuId  = ids[1]
                , charId = ids[2];
              if (event.element().hasAttribute('data-cell-id')){
                if (me.matrixInfo().is('loaded')){
                  var pathName = me.matrixInfo().isLastVersion() && me.iMode()._value == "edit" ? 'project_morphology_matrix_cell_path' : "show_cell_info_project_morphology_matrix_cell_path";
                  wndw.loadPage(pathName, {matrix_id: params['matrix_id'], id: event.element().readAttribute('data-cell-id')});
                }
              }else{
                me.matrixInfo().doIfLastVersion(function(){
                  wndw.loadPage('new_project_morphology_matrix_cell_path', {matrix_id: params['matrix_id'], extraParams: '?charId='+charId+'&otuId='+otuId});
                }, me)
              }
            }
          }
        }).bind(this)(event);
      }
    }
  })
});

