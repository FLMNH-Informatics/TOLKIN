//= require <page>


JooseModule('Admin.Users', function() {
  JooseClass('IndexPage', {
      isa: Page,
      has: {
          canRender: { is: 'ro', init: false }

      },
      after: {

      },
      methods: {
          onChange: function (event) {
              var me = this;
              Event.delegate({
                  'select#admin_project_select': function (event) {
                      new Ajax.Request('/admin/users?id='+ event.target.value, {
                          method: 'get',
                          requestHeaders: { Accept: 'text/html' },
                          onSuccess: function(response) {
                              $('users-table-holder').innerHTML = response.responseText
                              //window.location.reload(true); // force page refresh for now - TODO - update page appropriately with message / event passing
                          }
                      })


                  }
              }).call(this, event)
          } ,
          onClick: function (event) {
              var me = this;
              Event.delegate({
                  '#users-table-holder .pagination a': function (event) {
                      event.stop()
                      new Ajax.Request(event.target.href, {
                          method: 'get',
                          requestHeaders: { Accept: 'text/html' },
                          onSuccess: function(response) {
                              $('users-table-holder').innerHTML = response.responseText
                              //window.location.reload(true); // force page refresh for now - TODO - update page appropriately with message / event passing
                          }
                      })


                  }
              }).call(this, event)
          }
      }
  })
});