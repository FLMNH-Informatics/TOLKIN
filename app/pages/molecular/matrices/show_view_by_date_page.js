//= require <page>
//= require <html_loader>
//= require <molecular/matrix>

JooseModule('Molecular.Matrices', function () {
  JooseClass('ShowViewByDatePage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 450 },
      width:          { is: 'ro', init: 200 },
      title:          { is: 'ro', init: 'Matrix: Choose Date' },
      savable:        { is: 'ro', init: false },
      saveButtonText: { is:'ro', init: 'Select Date' },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_view_by_date_project_molecular_matrix_path'
      }, this)}}
    },
    methods: {
      onClick: function(event){
        var me = this;
        Event.delegate({
          ".expand_date" : function (event) {
            var dateString = event.element().dataset["date"]
              , partial_url = '/projects/' + params['project_id'] + '/molecular/matrices/' + params['matrix_id']
              , el = event.element()
              , tdArray = [];
            if (el.innerHTML == '[+]'){
              if (el.up('tr').next().down('td').innerHTML == ''){
                me.context().notifier().working('Fetching times...')
                new Ajax.Request(partial_url + '/get_times_for_date?date=' + dateString,{
                  method: 'get',
                  onSuccess: function (response) {
                    var timesArray = response.responseJSON.times.evalJSON();
                    timesArray.each(function(time){
                      var strNumTime = (parseInt(time[1])+1).toString(); //need to add 1 to include the record at this time
                      var trtd = '<tr><td class="time_of_day" ><a href="' + partial_url + '/view_by_date?date=' + strNumTime + '">' + time[0] + '</a></td></tr>';
                      tdArray.push(trtd);
                    })
                    el.up('tr').next().down('td').insert({bottom: '<table>' + tdArray.join('') + '</table>'});
                    me.notifier().success('Received times.');
                    el.innerHTML = '[ - ]';
                    el.up('tr').next('tr').toggle();
                  },
                  onFailure: function (response) {},
                  onComplete: function(response){}
                })
              }else{
                el.innerHTML = '[ - ]';
                el.up('tr').next('tr').toggle();
              }
            }else if (el.innerHTML == '[ - ]'){
              el.innerHTML = '[+]';
              el.up('tr').next('tr').toggle();
            }
          }
        }).call(this,event)
      }
    }
  })
})