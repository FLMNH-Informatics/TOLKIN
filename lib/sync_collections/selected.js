//= require <roles/fires_events>

JooseModule('SyncCollections', function () {
  JooseClass('Selected', {
    does: Roles.FiresEvents,
    has: {
      collection: { is: 'ro', required: true, nullable: false },
      ids: { init: function () { return new Sett() } },
      mode: { init: 'including' } // or 'excluding'
    },
    methods: {
      selectId: function (id) {
        if(this._mode == 'including') {
          this._ids.add(id);
        } else if(this._mode == 'excluding') {
          this._ids.remove(id);
        }
        this.fire('select', { memo: this });
      },
      deselectId: function (id) {
        if(this._mode == 'including') {
          this._ids.remove(id);
        } else if(this._mode == 'excluding') {
          this._ids.add(id);
        }
        this.fire('deselect', { memo: this });
      },
      selectAll: function () {
        this._ids.clear();
        this._mode = 'excluding';
        this.fire('selectAll', { memo: this });
      },
      deselectAll: function () {
        this._ids.clear();
        this._mode = 'including';
        this.fire('deselectAll', { memo: this });
      },
      size: function () {
        var val;
        switch(this._mode) {
          case 'including': val = this._ids.size(); break;
          case 'excluding': val = ((this._collection.count() || parseInt( $('collection_count').innerHTML, 10))- this._ids.size()); break;
          default:          val = null;
        }
        return val;
      },
      
      loadIds: function (options) {
        var params = this._collection.renderParams();
        params.select = 'id';
        params.conditions = this.conditions();
        this._collection._load({
          parameters: params,
          onSuccess: function (transport) {
            var ids = transport.responseJSON.requested.collect(function(entry) {
              return Object.value(entry).id
            });
            options.onSuccess(ids);
          },
          onFailure: function () {}
        });

      },

      conditions: function () { return this.toString() },

      serialize: function () { return this.toString(); },

      toString: function(){
        var idName = this._collection.type().primaryKey().name()
        var ids = this._ids.toString();
        var conds;

        switch(this._mode) {
          case 'including':
            conds = (ids == '' ? 'false' : ids+'['+idName+']');
            break;
            break;
          case 'excluding':
            conds = (ids == '' ? 'true' : ids+'[^'+idName+']');
        }
        if (conds == ''){
          conds = (this._collection.where() && this._collection.where().toString()) || 'false'
        }else{
          conds = [ conds,
                       this._collection.where() && this._collection.where().toString() 
                   ].compact().join('+').sub(/\+false/, '');
        }
        return conds;
      },
      toForm: function () {
        return this.toString();
      },
      destroy: function (contextObj) {
        var me = this;
        new Ajax.Request(contextObj.routes().pathFor(this._collection.type(), 'destroy_all'), {
            method: 'put',
            parameters: { conditions: this.toString() },
            onSuccess: function () {
              me._collection.context().notifier().success('Sequences deleted successfully');
              me._collection.fire('destroy', { memo: this });
              //context.notifier().success('Sequences successfully deleted');
            }
        })
        //this._collection.type().destroy(this.toString(), { context: this._collection.context() });
      },
      export_DNA: function (contextObj) {
        new Ajax.Request(contextObj.routes().pathFor(this._collection.type(), 'show_genbank_form'), {
            method: 'get',
            parameters: { conditions: this.toString() },
            onSuccess: function () {
              //this._collection.fire('destroy', { memo: this });
              //context.notifier().success('Sequences successfully deleted');
            }
        })
      },
      empty: function () {
        return this.toString() == 'false' ? true : false;
      },
      any: function () {
        return this.empty() ? false : true;
      }
    }
  });
});