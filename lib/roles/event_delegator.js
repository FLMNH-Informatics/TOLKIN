//= require <roles/registers_widgets>
JooseModule('Roles', function () {
  Role('EventDelegator', {
    does: TOLJS.role.RegistersWidgets,
    requires: [ 'id' ],
    methods: {
      delegateEvent: function(type, event) {
        if(typeof event.element == 'function') {
          var nextElement, delegateTo, scanAhead;
          // find next child widget
          nextElement = (event.element().up && event.element().up('.widget')) || 
            (event.element().hasClassName && event.element().hasClassName('widget') && event.element());
          if(nextElement && nextElement.id != this.id()) {
            while((scanAhead = nextElement.up('.widget')) && scanAhead.id != this.id()) {
              nextElement = scanAhead;
            }
            // pass event along to next child widget if it exists
            (delegateTo = this.widgets().get(nextElement.id)) &&
            (delegateTo.delegateEvent.bind(delegateTo)(type, event));
          }
          // respond to event if personal response specified
          var methodName = 'on' + type.capitalize();
          this.meta.can(methodName) && this[methodName](event);
        }
      }
    }
  });
});
