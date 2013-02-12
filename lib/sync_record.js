//= require <roles/observable>
//= require "sync_collection"
//= require "sync_records/attribute"
//= require <roles/stateful>
//= require <state>
//= require "special_event"

/** section: General
 *  class Model
 *
 *  Abstract class that can be subclassed to represent model objects on server.  It
 *  will take care of the communication with the server to perform common actions
 *  such as create, update, and destroy (note: create and update yet to be added).
 *  Subclass must provide klass variable to the constructor and requestPath as a
 *  method that will give the server communication path for a data object.
 *
 **/
JooseClass('SyncRecord', {
  does: [ TOLJS.role.Observable, Stateful ],
  classHas: {
    primaryKey: { is: 'ro', init: function () { return new SyncRecords.Attribute({ name: 'id' }) } },
    eventListenerStack: { init: function () { return {} } },
    eventsFiredSet: { init: function () { return new Sett() } }
  },
  has: {
    id:         {is: 'ro', init: null},
    context: { is: 'ro', required: true, nullable: false },
    data:       { is: 'ro', init: function () { return {} }},
    states:      { is: 'ro', init: function () { return $States([
      ['unloaded', 'loading', 'loaded']
    ], this) }},
    initLoader: { is: 'ro' }, // SyncCollection or SyncRecord object that will contain fetched data //TODO: not complete yet where it will actually use this loader data
    initLoaderFn: { }, // function (loaderAtts) should return simple object (hash) representing collection data
    include:    { },
    select:     { },
    order:      { },
    deleteSelectedMethod: { is: 'ro', init: 'delete_selected' },
    handlers: { is: 'ro', lazy: true, init: function () { return $Handlers([
      this.meta.getClassObject().on('recordUpdated', this.onRecordUpdated.bind(this)),
          //        a.on('' , b) -> b is listening on a
      this.on('create', this.meta.getClassObject().handleEvent.bind(this.meta.getClassObject())),
      this.on('update', this.meta.getClassObject().handleEvent.bind(this.meta.getClassObject())),
      this.on('destroy', this.meta.getClassObject().handleEvent.bind(this.meta.getClassObject()))
    ], this)}}
  },
  after: {
    initialize: function () {
      this.state().set('unloaded');
      this.handlers();
      this.meta.getClassObject().addObserver(this, this.onChange); }
  },
  methods: {
    state: function () {
      return this.states()
    },
    
    attributes: function () {
      return this.data()
    },

    onRecordUpdated: function (event) {
      //if(event.memo().record.meta.className() == this.meta.className()
      if(event.memo().id == this.id() || event.memo().record.id() == this.id()) {
        this.reload();
      }
    },

    order: function (order) {
      if(order == undefined) {
        return this._order
      } else {
        this._order = order;
        return this;
      }
    },

    unload: function () {
      this.handlers().expireAll()
      this.setState('unloaded')
    },

    select: function (select) {
      if(select == undefined) {
        return this._select
      } else {
        this._select = select;
        return this;
      }
    },

    include: function (include) {
      if(include == undefined) {
        return this._include
      } else {
        this._include = include;
        return this;
      }
    },

    onChange: function () {
      this.changed();
      this.notifyObservers();
    },

    isNewRecord: function () {
      return !this.id()
    },

    /**
     *  Model#destroy() -> undefined
     *
     *  TODO
     **/
    destroy: function(options) { alert('NOT IMPLEMENTED YET'); },

    deleteSelected: function (options){
      var selectedText = $$('.selected_count').length == 1 ? ($$('.selected_count').first().innerHTML + " ") : "the selected ";
      if (confirm("Are you sure you want to delete " + selectedText + (options.collectionString ? options.collectionString : "records") + "?")){
        var form = $('list_items_form');
        var me = this;
        me.context().notifier().working('Deleting' + (options.collectionString ? (" " + options.collectionString) : "") + "...")
        options = options || {};
        if (this.requestPath){
          form.writeAttribute('action', this.requestPath().sub('null','') + this._deleteSelectedMethod);
          form.request({
            method: 'delete',
            onSuccess: function (transport){
              me.fire('destroy');
              me.context().notifier().success((options.collectionString ? options.collectionString : "Records") + " deleted.")
              if (options.onSuccess){ options.onSuccess(); }
            },
            onFailure: function (transport){
              me.context().notifier().error('Something went wrong');
              if (options.onFailure) options.onFailure();
            }
          })
        }else{
          me.context().notifier().error('You must declare a requestPath method in the sync record');
        }
      }
    },

    refresh: function(options){
      new Ajax.Request(this.requestPath(),options)
    },

    reload: function(options) {
      this.loadAttributes(options);
    },

    loadAttributes: function (options) {
      this.load(options)
    },

    shortName: function () {
      return this.meta.getClassObject().shortName();
    },

    /**
     *  Model#loadAttributes(callback) -> undefined
     *  - callback (Function): function to call upon success of attribute loading
     *
     *  Retrieve attributes for this data object from server and store them locally.
     **/
    load: function(options) {
      if (this.handlers().allExpired()) {
        this.handlers().enableAll()
      }
      this.state().set('loading');
      options = options || {};
      var rand = Math.random();

      var shortName = this.shortName();
      var action     = this.isNewRecord() ? 'new' : 'show';
      var parameters;
      if(this.isNewRecord()) {
        parameters = $H(this.attributes()).inject({}, function (acc, pair) {
          acc[''+shortName+'['+pair.key+']'] = pair.value;
          return acc;
        })
      } else {
        parameters = {};
      }
      if(this._include) { parameters['include'] = (typeof this._include == 'string') ? this._include : Object.toJSON(this._include) }
      if(this._select)  { parameters['select']  = (typeof this._select == 'string')  ? this._select  : Object.toJSON(this._select)  }
      if(this._order)   { parameters['order']   = (typeof this._order == 'string')   ? this._order   : Object.toJSON(this._order)   }
      var path
      if(this.meta.getClassObject().memberRoute && this.meta.getClassObject().memberRoute()) {
        path = this.meta.getClassObject().memberRoute().getInterpolatedPath(Object.extend(params, { id: this.id() }))
      } else {
        path = this.context().routes().pathFor(this, action, { id: this.id() })
      }
      var model = this;
      var requestOptions = {
        method: 'get',
        parameters: parameters,
        requestHeaders: {
          Accept: 'application/json' },
        onSuccess: function (transport) {
          if(transport.responseText) {
            var response = Object.values(transport.responseText.evalJSON()).first();
            model._data = model._processLoad(response);
            model.state().set('loaded');
            //model._loaded = true;
            if(options.onSuccess) {
              options.onSuccess();
            }
            if(options.queue) { options.queue.flush(rand) }
          }
        }
      }
      this.meta.getClassObject().load(path, requestOptions);
      return rand
    },

    /**
     *  Model#update() -> undefined
     *
     *  TODO
     **/

   update: function(reqParams, options) {
    if(!(options.request === false)) {
      options = options || reqParams || {} ;
      reqParams = reqParams || {}
      var model = this;
      new Ajax.Request(this.requestPath(), {
        method: 'put', parameters: ($('taxon_update') && $('taxon_update').serialize()) || reqParams,
        requestHeaders: options['requestHeaders'] || { },
        onSuccess: $('taxon_update') ? function(transport) {
          model.reload({
            callback: function () {
              model.changed();
              model.notifyObservers();
              if(options.onSuccess) {
                options.onSuccess();
              }
            }
          });
        } : function () {
          if(options.onSuccess) {
            options.onSuccess();
          }
        },
        onFailure: function() {
          Notifier.error('failed to update data');
        }
      });
    } else {
      this._data = reqParams;
      this.fire('update', { memo: { record: this } });
    }
  },

  updateAttributes: function(attributes){
    var me = this;
    var shortName = this.meta.getClassObject().shortName();
    var outAtts = {};
    $H(attributes).each(function (pair) {
      outAtts[shortName+'['+pair.key+']'] = pair.value;
    });
    new Ajax.Request(this.context().routes().pathFor(this, 'update', { id: this.id() }), {
      method: 'put',
      parameters:outAtts,
      onSuccess: function (transport) {
        me.fire('update', { memo: me })
      }
    })
  },


    _loadHasManyRelation: function(relationName, options) {
      options = options || { }
      // build request parameters string that will go in URI
      var requestOptions =
      [ 'limit', 'order', 'offset', 'only', 'include' ].inject([ ], function(acc, option) {
        if(options[option]) {
          acc.push(option + "=" + options[option]);
        }
        return acc;
      }, this);
      requestOptions = (requestOptions.size() > 0) ? '?' + requestOptions.join('&') : '';

      var model = this;
      new Ajax.Request(this.requestPath() + "/" + relationName + requestOptions, {
        method: 'get',
        onSuccess: function(transport) {
          var response = transport.responseText.evalJSON();
          model[relationName] = response.requested.map(function(item) {
            return Object.values(item).first();
          });
          model[relationName + "_count"] = response.count;
          if(options.callback) {
            options.callback();
          }
        },
        onFailure: function() {
          this.parent().notifier().error('failed to load ' + relationName + ' data');
        }
      });
    },

    _processLoad: function(object) {
      return object;
    }
  },
  classMethods: {
    handleEvent: function (event) {
      switch(event.type()) {
        case 'create':
          this.fire('recordCreated');
          break;
        case 'update':
          this.fire('recordUpdated', { memo: event.memo()});
          break;
        case 'destroy':
          this.fire('recordsDestroyed', { memo: event.memo()});
          break;
      }
//      new Ajax.Request(options.context.routes().pathFor(this, 'delete_selected'), {
//        parameters: { where: ids },
//        onSuccess: function (trans) {
//          if(trans.responseText == 'ok'){
//             window.location.href=window.location.href
//          }
//        }
//      });
    },

    attr: function (attName) {
      return this.attribute(attName)
    },

    attribute: function (attName) {
      return new SyncRecords.Attribute({ name: attName })
    },

    shortName: function () {
      return this.meta.className().split('.').pop().singularize().toLowerCase();
    },

    request: function (route, options) {
      options = options || {}
      var modelClass = this;
      var requestedOnSuccess = options.onSuccess;
      options.onSuccess = (function (transport) {
        modelClass.changed();
        modelClass.notifyObservers();
        if(requestedOnSuccess) {
          requestedOnSuccess(transport);
        }
      });
      new Ajax.Request(route, options);
    },

    first: function (options, context, observer) {
      return new this({options: options, context: context});
    },

    context: function (context) {
      return new SyncCollection({context: context, type: this});
    },

    collection: function (options) {
  
      if(options.empty && delete options.empty) {
        return new EmptyCollection($H(options).merge({type: options.type || this }).toObject());
      } else {
        return new SyncCollection($H(options).merge({type: options.type || this }).toObject());
      }
      
    },

    all: function (params) {
      params = params || {};
      return new SyncCollection(Object.extend(params, {type: this})).load();
    },

    find: function (ids, context, observer) {
      var obj;
      if(typeof ids == 'number') {
        return new this({id: ids, context: context});
      } else {
        return new SyncCollection({context: context, type: this, ids: ids});
      }
    },

    load: function(path, options) {
      new Ajax.Request(path, options);
//        var parameters = options && options.parameters ? options.parameters : { }
//        new Ajax.Request(Model.Routes.get(modelType), {
//          method: 'get',
//          parameters: parameters,
//          onSuccess: function(transport) {
//            if(options.onSuccess) {
//              options.onSuccess(transport.responseText.evalJSON());
//            }
//          }
//        })
    },
    //// COPIED FROM OBSERVABLE ROLE - NEED ROLES FOR CLASS OBJECTS TOO
    /**
     *  Observable#addObserver(observer[, func = observer.update]) -> undefined
     *  - observer (Object): The object to be designated as observer.
     *  - func (Function): Function to call when `Observable` object is updated.
     *
     *  Subscribes observer object and function to `Observable` object.
    **/
    addObserver: function(observer, func) {
      if(!func) { func = observer.update; }
      if(!func) { throw new TOLJS.exception.NoMethodError("observer does not respond to 'update'"); }
      if(!this._observerPeers) { this._observerPeers = $H(); }
      this._observerPeers.set(observer.id, func.bind(observer));
    },

    /**
     *  Observable#deleteObserver(observer) -> undefined
     *  - observer (Object): The observing object.
     *
     *  Removes as an observable the object provided.
    **/
    deleteObserver: function(observer) {
      if(this._observerPeers) { this._observerPeers.unset(observer.id); }
    },

    /**
     *  Observable#deleteObservers() -> undefined
     *
     *  Removes every observer and listening function from this object.
    **/
    deleteObservers: function() {
      if(this._observerPeers) { this._observerPeers.keys().each(function(key) {
        this._observerPeers.unset(key);
      }); }
    },

    /**
     *  Observable#countObservers() -> Number
     *
     *  Returns a count of all observers for the `Observable` object.
    **/
    countObservers: function() {
      return this._observerPeers ? this._observerPeers.size() : 0;
    },

    /**
     *  Observable#changed([state = true]) -> undefined
     *  - state (Boolean): value for _changed_ property.
     *
     *  Flag to be set when the `Observable` object has changed its state in some
     *  significant way.  Also can be set to `false` if the `Observable` object
     *  should not be considered as _changed_.
    **/
    changed: function(state) {
      state = state || true;
      this._observerState = state;
    },

    /**
     *  Observable#isChanged() -> Boolean
     *
     *  Returns the value of the _changed_ property of the `Observable` object.
    **/
    isChanged: function() {
      return this._observerState ? true : false;
    },

    /**
     *  Observable#notifyObservers([argument...]) -> undefined
     *  - argument (?): Argument, one or many, to pass to observer listener
     *    functions.
     *
     *  Calls provided functions with the given arguments for all observers only
     *  if the _changed_ property of the `Observable` object is set to `true`
     *  (`changed` has been called at least once).
    **/
    notifyObservers: function() {
      if(this._observerState && this._observerPeers) {
        this._observerPeers.each(function(pair) {
          pair.value.apply(null, arguments);
        });
      }
      this._observerState = false;
    },

    fire: function (eventName, options) { 
      var event = new SpecialEvent({ type: eventName, from: this, memo: options && options.memo ? options.memo : options });
      var stack = this._eventListenerStack[eventName] || (this._eventListenerStack[eventName] = []);
      stack.each(function (listener, index) {
        if(listener.expired()) {
          stack.splice(index, 1);
        } else {
          this._fireFor(listener, event);
        }
      }, this);
    },
    _fireFor: function (listener, event) {
      if(!listener.expired()) {
        if(listener.expiresAfterNext()) {
          listener.expire();
        }
        listener.callback()(event);
      }
    },
    on: function (eventName, callback, options) {
      options || (options = {});
      this._eventListenerStack[eventName] || (this._eventListenerStack[eventName] = []);
      var listener = new IntEventHandler({ obj: this, eventName: eventName, callback: callback, options: options });
      if(options.once) {
        listener.expireAfterNext();
      }
      this._eventListenerStack[eventName].push(listener);
      return listener;
    }
  }
});

