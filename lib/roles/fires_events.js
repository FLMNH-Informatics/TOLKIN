//= require <special_event>
//= require <sett>
//= require <int_event_handler>

Module('Roles', function () {
  Role('FiresEvents', {
    has: {
      eventListenerStack: { init: function () { return {} } },
      eventsFiredSet: { init: function () { return new Sett() } }
    },
    methods: {
      fire: function (eventName, options) {
        var event = new SpecialEvent({ type: eventName, from: this, memo: (options ? options.memo : options)});
        //var event = new CustomEvent({ type: eventName, from: this, memo: options });
        var stack = this._eventListenerStack[eventName] || (this._eventListenerStack[eventName] = []);
        stack = stack.inject([], function (acc, listener) {
          if(!listener.expired()) {
            acc.push(listener);
          }
          return acc;
        });
        stack.each(function (listener, index) {
          this._fireFor(listener, event, options);
        }, this);
      },
      _fireFor: function (listener, event, options) {
        options || (options = {})
        if(!listener.expired()) {
          if(listener.expiresAfterNext()) {
            listener.expire();
          }
          listener.callback().call(listener.context(), event, options)
        }
      },
      on: function (eventNameOrObj, callbackOrContext, optionsOrContext, lastContext) {
        if(typeof eventNameOrObj == 'string') {
          return this._onSingle(eventNameOrObj, callbackOrContext, optionsOrContext, lastContext);
        } else {
          return this._onMultiple(eventNameOrObj, callbackOrContext); // no handling of passing in precreated handler for onMultiple
        }
      },

      _onSingle: function (eventName, callback, optionsOrContext, lastContext) {
        var context, options
        if(lastContext !== undefined) {
          context = lastContext
          options = optionsOrContext
        } else {
          context = optionsOrContext
        }
        var fullEventName = eventName
        var isEvent = false;
        if(eventName.match(/^state:/)) { isEvent = true; }
//        if(isEvent) { eventName = eventName.match(/^state:(.+)/)[1]; }
        options || (options = {});
//        var isState;
        if(isEvent) {
//          isState = true;
          eventName = eventName.sub(/^state:/, '');
        }
        this._eventListenerStack[eventName] || (this._eventListenerStack[eventName] = []);
        var handler = options.handler
        if (!handler) {
          handler = new IntEventHandler({ obj: this, eventName: fullEventName, callback: callback, options: options, context: context });
          if(options.once) {
            handler.expireAfterNext();
          }
        }
        this._eventListenerStack[eventName].push(handler);
        if(isEvent && (this.state && this.state().is(eventName) || (this.states && this.is(eventName)))) {
            this._fireFor(handler, new SpecialEvent({ type: eventName, from: this }));
        }
        return handler;
      },

      _onMultiple: function (obj, context) {
        var handlers = [];
        for(var key in obj) {
          key.split(',').each(function(eventName) {
            handlers.push(this._onSingle(eventName, obj[key].bind(context)));
          }, this);
        }
        return handlers;
      }
    }
  })
})
