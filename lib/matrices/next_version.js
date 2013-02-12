JooseRole('NextVersion', {
  after: {
    initialize: function () { this.context().notifier().working('Creating next version...') },
    onLoad: function () {
      var partialURL = "/projects/" + params["project_id"] + "/" + this.meta._name.split('.').first().toLowerCase() + "/matrices/"
        , showPage   = this.context().viewport().designatedFrame().page();
      this.context().notifier().success('Next version created');
      showPage.matrixInfo()._data.versions.push({"timeline": {
        "matrix_id": 93,
        "updated_at": (new Date(Date.now())).toISOString() }});
      this.setNewTimelineId($$('.' + this.meta._name.split('.').first().toLowerCase() + '_matrix_properties')[0].dataset.timeline_id);
      $('versioning_list').down('li.Create_next_version').toggle();
      $('version_navigation').down('td.versioning_change.next').innerHTML = '<a href="' + partialURL + this._newTimelineId + '">>></a>';
      $('version_navigation').down('td.versioning_change.end').innerHTML = '<a href="' + partialURL + this._newTimelineId + '">>|</a>';
    }
  },
  methods: {
    onClick: function (event) {
      var me = this;
      Event.delegate({
        'input[type="button"][value="Save"]': function (event) {
          var name = $('matrix_name').value
            , description = $('timeline_description').value;
          me.notifier().working('Updating...')
          new Ajax.Request('/projects/' + params['project_id'] + '/' + me.meta._name.split('.').first().toLowerCase() + '/matrices/' + me._newTimelineId + '/update_info',{
            parameters: {name: name, description: description},
            onSuccess: function(response){
              window.location = '/projects/' + params['project_id'] + '/' + me.meta._name.split('.').first().toLowerCase() + '/matrices/' + me._newTimelineId;
            },
            onFailure: function(response){}
          })
        }
      }).call(this,event)
    }
  }
})