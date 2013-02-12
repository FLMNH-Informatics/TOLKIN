//= require "global_cart"
//= require "current_selection"

Module('TOLKIN', function () {
  JooseClass('Session', {
    has: { context: { is: 'ro', nullable: false, required: true }},
    methods: {
      load: function () {
        var session = this;
        if(params['project_id']) {
          new Ajax.Request("/projects/" + params['project_id'] + "/session", {
            method: 'get',
            onSuccess: function(transport) {
              var response = transport.responseText.empty() ? {} : transport.responseText.evalJSON();
              !session.context().interactMode().get() &&
              (session.context().interactMode()._value = response.interact_mode || 'browse') &&
              session.context().interactMode().setState('loaded')
              //session.context().setInteractMode(    );
//              session.context().setGlobalCart(      new TOLKIN.GlobalCart({notifier: session.context().notifier(), value: response.cart || {}, index: response.cart_index || {} }));
//              session.context().currentSelection().set(response.current_selection, { request: false });
//              session.context().fire('globalCart:loaded');
//              session.context().fire('currentSelection:loaded');
            },
            onFailure: function() {
              session.context().notifier().error('failed to load interaction mode');
            }
          });
        }
      }
    }
  })
});
