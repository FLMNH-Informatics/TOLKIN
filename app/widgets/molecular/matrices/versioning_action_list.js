//= require <widget>

JooseModule('Molecular.Matrices', function () {
  JooseClass('VersioningActionList', {
    isa: Widget,
    has:   {
      context: { is: 'ro', required: true, nullable: false },
      partialUrl: { is: 'rw', init: null}
    },
    after: {
      initialize: function () {this.setPartialUrl("/projects/" + params['project_id'] + "/molecular/matrices/");}
    },
    methods: {
      onClick: function (event) {
        var url_fragment = "/projects/" + params['project_id'] + "/molecular/matrices/" + params['matrix_id']
          , me = this;
        Event.delegate({
          '.Create_next_version': function(event){
            event.stop();
            me.context().frame().page().matrixInfo().doIfLastVersion(function(){
              params["id"] = params["matrix_id"]; //set params id  to matrix id in case a cell has been clicked
              var confirmed = confirm('Do you want to create the next version for this matrix?')
                , pageName = me.context().frame().page().meta._name.split('.').last();
              if(confirmed){
                me.notifier().working('Creating next version')
                new Ajax.Request(me.context().routes().pathFor('create_next_version_project_molecular_matrix_path'), {
                  method: "post",
                  parameters: {'page': pageName},
                  onSuccess: function (response){
                    me.notifier().success('Next version created');
                    if(pageName == "ModifyMatrixPage"){
                      window.location = me.context().routes().pathFor('modify_matrix_project_molecular_matrix_path',{id: response.responseJSON.timeline_id});
                    }else{
                      me.context().frame().page().matrixInfo()._id = me.context()._params["id"] = params["id"] = params["matrix_id"] = params["mol_matrix_id"] = response.responseJSON.timeline_id;
                      me.context()._params["id"] = response.responseJSON.timeline_id;

                      //declare vars after context is changed
                      var updatedPanes = response.responseJSON.timeline_display_pane + response.responseJSON.action_list_pane + response.responseJSON.submatrix_views
                        , pageTitle = "Tolkin - matrices : " + pageName == "ShowPage" ? "show" : "modify matrix"
                        , pagePath = me.context().routes().pathFor((pageName == "ShowPage" ? '' : 'modify_matrix') + 'project_molecular_matrix_path')
                        , sortingLinks = response.responseJSON.sorting_links.split(',');

                      $w('otus markers both').each(function(type, i){ $('sort_' + type).update(sortingLinks[i]); })
                      $(me.parent()._id).update(updatedPanes);
                      $$('.matrix_title').first().update(response.responseJSON.matrix_title);
                      history.pushState(me.context()._params, pageTitle, pagePath);
                    }
                  }
                })
              };
            }, me)
          },
          '.View_history_by_date':   function(event){
            event.stop();
            me.viewport().widget('window').loadPage('show_view_by_date_project_molecular_matrix_path', {id: params["matrix_id"]})
          }
        }).call(this, event)
      },
      onChange: function(event){
        var me = this;
        if (event.element() == $('timeline_version_select')){
          if (!(params["matrix_id"].toString() == event.element().value)){
            me.context().notifier().working('Switching to version ' + event.element().options[event.element().selectedIndex].text + '...')
            window.location = me._partialUrl + event.element().value
          }
        }
      }
    }
  })
})