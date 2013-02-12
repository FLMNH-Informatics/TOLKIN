//= require <widget>

JooseModule('Molecular.Matrices', function () {
  JooseClass('ActionList', {
    isa: Widget,
    has:   { context: { is: 'ro', required: true, nullable: false } },
    after: {
      initialize: function () {}
    },
    methods: {
      onClick: function (event) {
        var url_fragment = "/projects/" + params['project_id'] + "/molecular/matrices/" + params['matrix_id']
          , me = this;
        Event.delegate({
          '.Edit_Markers_and_Otus': function(event){
            event.stop();
            var new_pathname = url_fragment + "/modify_matrix"
              , fn = (function(){if (window.location.pathname != new_pathname){window.location = new_pathname;}});
            me.context().frame().page().matrixInfo().doIfLastVersion(fn, me.context().frame().page());
          },
//          '.Bulk_Sequence_Exporter':function(event){
//            if (event.element().nodeName == "LI"){
//              window.location = event.element().down().pathname
//            }
//          },
          '.View_history_by_date': function(event){ me.viewport().widget('window').loadPage('show_view_by_date_project_molecular_matrix_path') },
          '.View_Matrix': function (event){window.location = url_fragment;},
          '.Copy_this_matrix':   function(event){
            event.stop();
            if (me.iMode()._value == 'edit'){
              if (confirm('Copy this date into usable matrix?')){
                me.viewport().widget('window').loadPage('show_copy_matrix_project_molecular_matrix_path', {date: params["date"]})
              }
            }else{me.notifier().notify('You must be in edit mode to complete that action.')}
          },
          '.Autofill_matrix': function (event) {
            me.context().frame().page().matrixInfo().doIfLastVersion( function () {
              me.viewport().widget('window').loadPage('show_autofill_matrix_project_molecular_matrix_path')
            }, me.context().frame().page())
          }
        }).call(this, event)
      }
    }
  })
})