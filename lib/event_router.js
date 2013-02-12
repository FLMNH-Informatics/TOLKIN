//= require <lowpro>

/** section: Library
 *  class Event.Routes
 *
 *  The Event.Routes class defines and handles the task of delegating all occurring
 *  browser events to the appropriate handling objects (Widgets in most cases).
 *
 **/
Module('TOLKIN', function() {
  JooseClass('EventRouter', {
    has: {
      viewport: { is: 'ro', required: true, nullable: false },
      mouseDown: { init: false },
      drag: { init: false }
    },
    after: {
      initialize: function() {
        var router = this;
        var behaviors =
        ['click', 'dblclick', 'keyup', 'change', 'submit', 'mouseover', 'mouseout', 'mousemove', 'mouseup', 'mousedown', 'blur'].inject({}, function(hash, type) {
          hash['html:' + type] = function(event) {
            router._handleEvent(type, event);
          }
          return hash;
        });
        EVENTS_CACHE.stopListening();
        Event.addBehavior(behaviors);
        EVENTS_CACHE.cache.each(function (entry) {
          this._handleEvent(entry[0], entry[1]);
        }, this);
        EVENTS_CACHE.cache.clear();
      }
    },
    methods: {
      _handleEvent: function (type, event) {
       /* switch(type) {
          case 'mousedown':
            this._mouseDown = event;
            break;
          case 'mouseup':
            if(this._drag) { 
              this._delegateEvent('dragend', this._mouseDown);
              this._delegateEvent('dragend', event);
              this._drag = false;
            }
            delete this._mouseDown;
            break;
          case 'mousemove':
            if(this._mouseDown) {
              if(!this._drag) { this._drag = true; this._delegateEvent('dragstart', this._mouseDown); }
              this._delegateEvent('drag', event);
            }
            break;
        }*/
        this._delegateEvent(type, event);
      },

      _delegateEvent: function(type, event) {
        try {
          this.viewport().delegateEvent(type, event)
//          if(event.element()) {
//            var frameElement = event.element().hasClassName('frame') ? event.element() : (event.element().up('.frame') || document );
//            var viewport = this.session().viewport();
//            (viewport.widgets().get(frameElement.id) || viewport ).onEvent(type, event);
//          }
//          if(classElement) {
//            var widgetType = ('_' + classElement.readAttribute('data-widget-type')).dasherize().camelize();
//            var id = classElement.readAttribute('id');
//            if(!widgetType) {
//              throw new TOLJS.Exception(
//                "event occurred on widget with id #{id} but data-widget-type attribute was not found".interpolate({
//                  id: id
//                }));
//            }
//            this.session().widgets().get(id)['on' + ('-' + type).camelize()](event);
//          }
        } catch(error) {
          this.viewport().notifier().error(error);
          throw(error);
        }
      }
    }
  })
})

