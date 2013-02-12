//= require <widget>

JooseModule('Morphology.Matrices', function () {
  JooseClass('ActionList', {
    isa: Widget,
    has: { context: { is: 'ro', required: true, nullable: false}},
    after: {
      initialize: function(){}
    },
    methods: {
      onClick: function (event) {
        event.stop()
        var url_fragment = "/projects/" + params['project_id'] + "/morphology/matrices/" + params['matrix_id']
          , me = this;
        Event.delegate({
          '.View_current_matrix': function(event){ window.location = url_fragment; },
          '.View_matrix': function (event){window.location = url_fragment;},
          '.Edit_Characters_and_Otus': function(event){
            var new_pathname = url_fragment + "/modify_matrix"
              , fn = (function(){if (window.location.pathname != new_pathname){window.location = new_pathname;}});
            me.context().frame().page().matrixInfo().doIfLastVersion(fn, me.context().frame().page());
          },
          '.View_history_by_date': function(event){ me.viewport().widget('window').loadPage('show_view_by_date_project_morphology_matrix_path') },
          '.Copy_this_matrix':     function(event){
            if (me.iMode()._value == 'edit'){
              if (confirm('Copy this date into usable matrix?')){
                me.viewport().widget('window').loadPage('show_copy_matrix_project_morphology_matrix_path', {date: params["date"]});
              }
            }else{me.notifier().notice('You must be in edit mode to complete that action.')}
          },
          '.Export_Nexus_file': function (event){
            window.location = '/projects/' + params['project_id'] + '/morphology/matrices/' + params['matrix_id'] + '/do_export';
            me.notifier().success('Generating file...')
          }
        }).call(this, event)
      }
    }
  })
})