//= require <widget>

JooseModule('Morphology.Matrices', function () {
  JooseClass('VersioningActionList', {
    isa: Widget,
    has:   {
      context: { is: 'ro', required: true, nullable: false },
      partialUrl: { is: 'rw', init: null}
    },
    after: {
      initialize: function () {
        this.setPartialUrl("/projects/" + params['project_id'] + "/morphology/matrices/");
      }
    },
    methods: {
      onClick: function (event) {
        var url_fragment = "/projects/" + params['project_id'] + "/morphology/matrices/" + params['matrix_id']
          , me = this;
        Event.delegate({
          '.Create_next_version': function(event){
            me.context().frame().page().matrixInfo().doIfLastVersion(function(){
              var confirmed = confirm('Do you want to create the next version for this matrix?');
              if(confirmed){ me.viewport().widget('window').loadPage('show_next_version_project_morphology_matrix_path') };
            }, me)
          },
          '.View_history_by_date':   function(event){ me.viewport().widget('window').loadPage('show_view_by_date_project_morphology_matrix_path') }
        }).call(this, event)
      },
      onChange: function(event){
        var me = this;
        if (event.element() == $('timeline_version_select')){
          if (!(params["matrix_id"].toString() == event.element().value)){
            me.context().notifier().working('Switching to version ' + event.element().options[event.element().selectedIndex].text + '...');
            window.location = me._partialUrl + event.element().value;
          }
        }
      }
    }
  })
})