JooseRole('ActionPanelUpload', {
  after: {
    onClick: function (event) {
      var me = this;
      Event.delegate({
        'input[type="button"][value="Bulk Upload"]': function (){
          var type = this.meta._name.split('.Catalogs.ActionPanel').first().toLowerCase().split('.').join('_');
          window.location = me.context().routes().pathFor('show_new_upload_project_' + type + '_path')
        }
      }).call(this,event)
    }
  }
})