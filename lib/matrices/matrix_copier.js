JooseRole('MatrixCopier', {
  after: {
    initialize: function () {
      var matrixData = this._parentPage().records().get('matrixInfo')._data
      this.setMatrixName(matrixData.matrix.matrix.name);
      this.setTimelineDescription(matrixData.timeline.timeline.description);
    },
    onLoad: function(){
      //get date or use currentdate and put it in dateString format
      function pad(n){ return n<10 ? '0' + n : n }
      var d = new Date(Date.now())
      var dateString = params["date"] ||
        (d.getUTCFullYear().toString() +
          pad(d.getUTCMonth() + 1) +
          pad(d.getUTCDate()) +
          pad(d.getUTCHours()) +
          pad(d.getUTCMinutes()) +
          pad(d.getUTCSeconds()) +
          pad(d.getUTCMilliseconds())
        )
      function displayNewName(dateString, oldName){
        var year   = dateString.substr(0,4)
          , month  = dateString.substr(4,2)
          , day    = dateString.substr(6,2)
          , hours  = dateString.substr(8,2)
          , mins   = dateString.substr(10,2)
          , secs   = dateString.substr(12,2)
          , months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
          , date = new Date(year,month,day,hours,mins,secs);
//                      output like [copy]name[dayInt ShortMonth Time(24hrs) eg [copy]test[31 Jan 14:56]
        return "[copy]" + oldName + "[" + day + " " + months[date.getMonth() - 1] + " " + hours + ":" + mins + " UTC]";
      }
      $('matrix_name').value = displayNewName(dateString, this._matrixName);
      $('timeline_description').value = this._timelineDescription;
    }
  },
  methods: {
    copyMatrix: function () {
      var me = this
        ,  name = $('matrix_name').value
        , description = $('timeline_description').value
        , matrixUrl = '/projects/' + params['project_id'] + '/' + me.meta._name.toLowerCase().split('.').first() + '/matrices/';
      this.notifier().working('Copying...');
      new Ajax.Request(matrixUrl + params["id"] + "/copy_matrix", {
        parameters: {
          name: name,
          description: description,
          date: params["date"]
        },
        onSuccess: function(response){
          me.notifier().working('Matrix copied.  Loading...')
          window.location = matrixUrl + response.responseJSON.id
        },
        onFailure: function(response){
          me.notifier().error('Error: Something went wrong.')
        }
      })
    }
  }
})