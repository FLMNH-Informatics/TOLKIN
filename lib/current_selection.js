//= require <roles/observable>

Module('TOLKIN', function() {
  JooseClass('CurrentSelection', {
    does: TOLJS.role.Observable,
    has: {
      context: { is: 'ro', required: true, nullable: false },
//      notifier: { is:'ro', required : true, nullable : false },
      value: { }//,
    },
    methods: {
      get: function() {
        return this._value;
      },

      set: function(value, type, options) {
        options || (options = {});
        if(options.request !== false) {
          options.request = true;
        }

        var me = this;
        var prevValue = this._value;
        
        if(Object.isArray(value)) {
          if(value.size() > 1) {
          } else {
            this._value = value;
          }
        } else {
        
        if(prevValue) {
          this.changed();
          this.notifyObservers();
        }

        this._value = !Object.isArray(value) ? value : {
            type: type.capitalize(),
            label: type.capitalize() + '(' + value.compact().size() + ')' ,
            group: true
          };
        
//                InternalNotifier.subscribe(this.handleUpdate.bind(this), 'CurrentSelection',
//                    this._item.klass, this._item.id);
        }
        if(options.request) {
          new Ajax.Request('/projects/' + params['project_id'] + '/session/current_selection', {
            parameters: me._value,
            method: 'put',
            onFailure: function() {
              me.context().notifier().error('problem updating current selection');
            }
          });
        }
      },

      unset: function (options) {
        this.remove(options);
      },

      remove: function(options) {
        var me = this;
        options = options || {};
        this._value = null;
        this.changed();
        this.notifyObservers();
        new Ajax.Request('/projects/' + params['project_id'] + '/session/current_selection', {
          method: 'delete',
          onSuccess: function() {
            if(options.onSuccess) {
              options.onSuccess();
            }
          },
          onFailure: function() {
            me.context().notifier().error('problem removing current selection');
          }
        });
      }
    }
  })
});
  
