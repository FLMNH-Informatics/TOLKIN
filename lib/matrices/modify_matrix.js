JooseRole('ModifyMatrix', {
  methods: {
    removeObjects: function(type){
      var conftext = "Are you sure you want to remove the selected "
        , objects = (type == 'otu' ? type.toUpperCase() : type.capitalize()) + '(s)'
        , me = this
      if (confirm(conftext + objects)){
        me.context().notifier().working('Removing ' + objects + '...');
        document.getElementById('form_' + type + '_list').request({
          requestHeaders: {Accept: "application/json"},
          onSuccess: function (transport) {
            $('form_' + type + '_list').replace(transport.responseJSON.list);
            me.context().notifier().success(objects + ' removed.')
          }
        })
      }
    },
    onClick: function(event) {
      var me = this;
      Event.delegate({
        'input:checkbox': function(event){me.shiftCheck(event);},
        '#edit_matrix': function(event){
          me.matrixInfo().doIfLastVersion(function(){
            me.frame().viewport().widget('window').loadPage('edit_project_' + me.meta._name.split('.').first().toLowerCase() + '_matrix_path')
          }, me)},
        '.hovhand': function (event) {
          me.matrixInfo().doIfLastVersion(function(){
            event.element().localName == 'img' ? me.processMove(event.element()) : me.processMove(event.element().down('img'));
          }, me);
        },
        'a': function(event) {
          switch (event.element().readAttribute('id')) {
            case 'del_otu':
              me.matrixInfo().doIfLastVersion(function(){me.removeObjects('otu');}, me);
              break;
            case 'add_otu':
              me.matrixInfo().doIfLastVersion(function(){me.frame().viewport().widget('window').loadPage('show_add_otu_project_' + me.meta._name.split('.').first().toLowerCase() + '_matrix_path');}, me);
              break;
            case 'del_marker':
              me.matrixInfo().doIfLastVersion(function(){me.removeObjects('marker');}, me);
              break;
            case 'add_marker':
              me.matrixInfo().doIfLastVersion(function(){me.frame().viewport().widget('window').loadPage('show_add_marker_project_molecular_matrix_path');}, me);
              break;
            case 'del_character':
              me.matrixInfo().doIfLastVersion(function(){me.removeObjects('character');}, me);
              break;
            case 'add_character':
              me.matrixInfo().doIfLastVersion(function(){me.frame().viewport().widget('window').loadPage('show_add_character_project_morphology_matrix_path');}, me);
              break;
          }
        }
      }).call(this, event)
    },
    onSubmit: function(event){ },
    processMove: function (el){
      this.context().notifier().working('Moving...')
      var projectId = el.dataset.projectId
        , matrixId  = el.dataset.matrixId
        , objIdName = el.dataset.type + '_id'
        , objId     = el.dataset[el.dataset.type + 'Id']
        , moveType  = el.dataset.move
        , ajaxPath  = '/projects/' + projectId + '/' + this.meta._name.split('.').first().toLowerCase() + '/matrices/' + matrixId + '/change_position?' + objIdName + '=' + objId + '&move=' + moveType + '&type=' + el.dataset.type
        , me = this;
      me.context().notifier().working('Moving...')
      new Ajax.Request(ajaxPath, {
        method: 'post',
        onSuccess:  function (response) {
          if (response.responseJSON.error){
            me.context().notifier().error(response.responseJSON.error)
          }else{
            me.context().notifier().success('Move successful')
            $$('table.modify_matrix_table')[0].select('td.align_top')[response.responseJSON.type == 'otu' ? 0 : 1].innerHTML = response.responseJSON.html
          }
        },
        onFailure:  function (response) {me.context().notifier().error('Something went wrong.')},
        onComplete: function (response) {}
      })
    }
  }
})