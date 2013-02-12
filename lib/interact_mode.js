//= require <roles/observable>
//= require <roles/fires_events>
//= require <roles/stateful>

Module('TOLKIN', function () {
  JooseClass('InteractMode', {
    does: [ TOLJS.role.Observable, Stateful ],
    has: {//TODO: notifier is currently not being set at all
      context: { is: 'ro', required: true, nullable: false }, //,  required: true, nullable: false},
      value: { },//required: true, nullable: false }
      states: { is: 'ro', init: function () { return $States([
        [ 'unloaded', 'loaded' ]
      ], this) } }
    },
    after: {
      initialize: function () {
        if(!this._value) { this.setState('unloaded') }
      }
    },
    methods: {
      toString: function () {
        return this.get();
      },

      notifier: function () {
        return this.context().notifier();
      },

      get: function() {
        return this._value;
      },

      set: function(value, options) {
        options = options || {};
        var me = this;
        this._value = value;
        this.changed();
        this.notifyObservers();
        //moved into onsuccess, might not work:  this.fire('change', { memo: this }) // change is a good name for an event to fire on as well
        this.fire('set', { memo: this });
        var imode = this;
        //catch on projects edit
        if(typeof(params['project_id']) == 'undefined' && typeof(params['id']) != 'undefined'){
          //not sure if this is safe cause 'id' could mean something other then project_id in certain cases
          params['project_id'] = params['id'];
        }
        //what if mode change is not in a project? like new project?
        var path;
        if(typeof(params['project_id']) != 'undefined'){
          path = "/projects/" + params['project_id'] + "/session/interact_mode"
        }else{
          path = "/session/interact_mode"
        }
        new Ajax.Request(path, {
          method: 'put',
          parameters: {
            interact_mode: value
          },
          onSuccess: function() {
            me.fire('serverSet', { memo: me });
            me.fire('change', { memo: me }); // change is a good name for an event to fire on as well
            if(options.onSuccess) {
              
              options.onSuccess();
            }
          },
          onFailure: function() {
            imode.notifier().error('failed to set interact mode');
          }
        })
      }
    }
  })
});
