//= require "registers_widgets"

Module('TOLJS.role', function() {
  Role('SavvyParent', {
    does: TOLJS.role.RegistersWidgets,
    requires: [ 'notifier' ],
    methods: {
      top: function () {
        return this.parent ? this.parent().top() : this;
      }
    }
  })
});
