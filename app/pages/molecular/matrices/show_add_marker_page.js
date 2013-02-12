//= require <page>
//= require <html_loader>
//= require <molecular/matrix>

JooseModule('Molecular.Matrices', function () {
  JooseClass('ShowAddMarkerPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 450 },
      width:          { is: 'ro', init: 700 },
      title:          { is: 'ro', init: "Matrix:  Add Marker(s)"},
      records:        { is: 'ro', lazy: true, init: function () { return $Records({
            matrix: new Molecular.Matrix({ context: this.context(), data: {} })
      }, this)} },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Add Marker(s)'},
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_marker_project_molecular_matrix_path'
      }, this ) } }
    },
    methods: {
      onClick: function (event) {
        var chklist = $('marker_checkbox_list')
          , toggle = $('mrk_sel_all')
          , me = this;

        Event.delegate({
          'input[type="button"][value="Add Marker(s)"]': function (event) {
            if (chklist.getElementsBySelector('input:checkbox:checked').length < 1 && $('new_marker').value == ""){
              alert('You must select a marker or enter a new marker');
            }else{
              this.request(this.frame().element().down('form'));
            }
          },
          'a[id="mrk_sel_all"]': function (event) {
            var chks = chklist.getElementsBySelector('input:checkbox');
            switch (toggle.innerHTML){
              case 'select all':
                toggle.innerHTML = 'select none';
                chks.each(function(e){ e.checked = 1 });
                break;
              case 'select none':
                toggle.innerHTML = 'select all';
                chks.each(function(e){ e.checked = 0 });
                break;
            }
          },
          'input:checkbox': function (event) {
            this.shiftCheck(event);
          }
        }).call(this, event)
      },
      onSubmit: function (event) {
        event.stop();
        this.request(event.element());
      },
      request: function (form) {
        var me = this;
        this.notifier().working('Adding marker to matrix');
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close();
            if (transport.responseJSON){
              if (transport.responseJSON.message){
                me.notifier().error(transport.responseJSON.message);
              }else{
                $('form_marker_list').replace(transport.responseJSON.marker_list)
                me.notifier().success('Marker(s) successfully added to matrix.')
              }
            }
          },
          onFailure: function (transport) {
            me.frame().close();
            me.notifier().error("ERROR");
          }
        })
      }
    }
  })
});