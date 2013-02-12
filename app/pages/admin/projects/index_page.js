//= require <page>


JooseModule('Admin.Projects', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false }

    },
    after: {

    },
    methods: {
        onClick: function (event) {
            var me = this;
            Event.delegate({
                '#admin-projects-table tbody tr': function (event) {

                      window.location = "/admin/projects/" + event.target.up('tr').id

                }
            }).call(this, event)
        }
    }
  })
});