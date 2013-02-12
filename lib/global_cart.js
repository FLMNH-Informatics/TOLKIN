//= require <roles/observable>

Module('TOLKIN', function() {
  JooseClass('GlobalCart', {
    does: TOLJS.role.Observable,
    has: {
//      loaded: { is: 'ro', isa: Joose.Type.Bool, init: false, nullable: false },
//      currentCartSelection: { is: 'ro', init: null },
      index: { required: true, nullable: false },
      value: { required: true, nullable: false },
      notifier: { is: 'ro', required: true, nullable: false}
//      myCartSaved: { init: null },
//      deleteFromCart: { init: null }
    },
    methods: {
      sizeForType:function(type){
        return this._value[type].size();
      },

//      load: function(saved_value) {
////        this._loaded = true;
//        this._value = saved_value;
//      },

//      handleCurrentCartSelection: function(eventName){
//
//      },

      get: function (type, id) {
        return this._index[type] && this._index[type][id]
      },

      getAll: function () {
        return this._value;
      },

      getForType: function (type) {
        return this._value[type] || [];
      },

      removeForType: function (type) {
        var cart = this;
        delete this._index[type];
        delete this._value[type];
        this.changed();
        this.notifyObservers();
        new Ajax.Request('/projects/' + params['project_id'] + '/session/cart/'+type+'', {
            method: 'delete',
            onFailure: function() {
              cart.notifier().error('Problem updating global cart.');
            }
        });
      },

      add: function(type,id,name) {
          
        // discard duplicates
        if(!this._index[type] || !this._index[type][id]) {
          // if no duplicates, add item to cart and cart index
          this._value[type] = this._value[type] || [];
          var cartLoc = this._value[type].push({ id: id, label: name }) - 1; // keep track of where item was entered in array
          this._index[type] = this._index[type] || {};
          this._index[type][id] = { label: name, loc: cartLoc };
          this.changed();
          this.notifyObservers('change');         
          var cart = this;          
          new Ajax.Request('/projects/' + params['project_id'] + '/session/cart', {
            parameters: { type: type, id: id, label: name },
            method: 'put',
            onFailure: function() {
              cart.notifier().error('problem updating current selection');
            }
          });
        }       

      },

      onContentChange: function(model_event) {
        var type = model_event.data.getType()
        model_event.data.ids.each(function(id){
        if(this._index[type] && this._index[type][id]) {
          remove(type,id);
        }
        });

      },

      remove:function(type,id){
        if(this._index[type] && this._index[type][id]){
          var arrLoc = this._index[type][id].loc;
          delete(this._index[type][id]);
          this._value[type][arrLoc] = null;
//          this._value[type].splice(arrLoc, 1);
          this.changed();
          this.notifyObservers('onChange');          
          var cart = this;
          new Ajax.Request('/projects/' + params['project_id'] + '/session/cart/'+type+'/'+id, {
            parameters: { type: type, id: id },
            method: 'delete',
            onFailure: function() {
              cart.notifier().error('problem updating current selection');
            }
          });
      }
      }
    }
  })
});

