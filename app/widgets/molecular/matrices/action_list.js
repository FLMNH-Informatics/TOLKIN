//= require <widget>

JooseModule('Molecular.Matrices', function () {
  JooseClass('ActionList', {
    isa: Widget,
    has:   { context: { is: 'ro', required: true, nullable: false } },
    after: {
      initialize: function () {}
    },
    methods: {

      //todo: refactor _matrixInfo into the rest of this
      _matrixInfo: function (){ return this.context().frame().page().matrixInfo(); },
      _parentPage: function (){ return this.context().frame().page(); },
      _datagrid:   function (){ return this._parentPage().widgets().get('datagrid'); },

      onClick: function (event) {
        var url_fragment = "/projects/" + params['project_id'] + "/molecular/matrices/" + params['matrix_id']
          , me = this;
        Event.delegate({
          '.Edit_Markers_and_Otus': function(event){
            event.stop();
            var new_pathname = url_fragment + "/modify_matrix"
              , fn = (function(){if (window.location.pathname != new_pathname){window.location = new_pathname;}});
            me._matrixInfo().doIfLastVersion(fn, me._parentPage());
          },

          '.View_history_by_date': function(event){ me.viewport().widget('window').loadPage('show_view_by_date_project_molecular_matrix_path', {id: params["matrix_id"]}) },

          '.View_Matrix': function (event){window.location = url_fragment;},

          '.Copy_this_matrix':   function(event){
            event.stop();
            if (me.iMode()._value == 'edit'){
              if (confirm('Copy this date into usable matrix?')){
                me.viewport().widget('window').loadPage('show_copy_matrix_project_molecular_matrix_path', {id: params["matrix_id"], date: params["date"]})
              }
            }else{me.notifier().notify('You must be in edit mode to complete that action.')}
          },

          '.Autofill_matrix': function (event) {
            event.stop();
            me.context().frame().page().matrixInfo().doIfLastVersion( function () {
              me.viewport().widget('window').loadPage('show_autofill_matrix_project_molecular_matrix_path', {id: params["matrix_id"]})
            }, me._parentPage())
          },

          '#Enter_export_mode': function (event){
            this._datagrid().toggleExportMode();
          }
        }).call(this, event)
      }
    }
  })
})