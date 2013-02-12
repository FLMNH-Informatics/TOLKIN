//= require <roles/registry>
//= require <roles/fires_events>

/** section: General
 *  class Registry
 *
 *  General class for keeping record of other objects.
 *
 **/
JooseClass('Registry', {
  does: [ TOLJS.role.Registry, Roles.FiresEvents ],
  has: {
    owner: { is: 'ro', required: true, nullable: false },
    registry:    { init: function () { return $H() } },
    altRegistry: { init: function () { return $H() } },
    initial: { is: 'ro' }
  },
  after: {
    initialize: function () {
      if(this.initial()) {
        this.add($H(this.initial()));
      }
    }
  },
  methods: {
    each: function (func, context) {
      return this._altRegistry.each(func, context);
    },

    /**
     *  Registry#get(className, id) -> Object
     *  - className (String): class of object to retrieve
     *  - id (String): identifier for object to retrieve
     *
     *  Retrieves object from registry corresponding to provided class name
     *  and id.
     **/
    get: function(id) {
      return this._registry.get(id) || this._altRegistry.get(id);
    },
    /**
     *  Registry#add(object...) -> undefined
     *  - object (Object | Array): single object, a list of objects, or an
     *    array of objects, or hash of objects to be added to the registry.
     *    Hash of objects being added can either have object nicknames tied to
     *    single objects or a nickname tied to a group of objects.  Objects being
     *    added must have an id and be of the correct class specified in the
     *    constructor as `contentsClassName`.
     *
     *  Add one or multiple objects to the registry.
     **/
    add: function(firstObj) {
      var it, toAdd;
      if(arguments.length > 1) {
        toAdd = Array.prototype.slice.call(arguments)
      } else if(Object.isHash(firstObj)) {
        firstObj.each(function (item) {
          // add to additional registry by initial keys if user provides hash object
          if(item.value instanceof Array) {
            // whats the harm in not destroying what was previously there ? - im probably going to regret this
          } else {
            if((it = this._altRegistry.get(item.key)) && it != item.value) { it.unload() }
          }
          this._altRegistry.set(item.key, item.value);
        }, this);
        toAdd = firstObj.values().flatten();
      } else {
        toAdd = [arguments[0]].flatten()
      }
      toAdd.each(function(object) {
        // if there is already a registry entry for this className and id call
        // destroy on that registryed object
        if(object) {
          if((it = this._registry.get(object.id())) && it != object) {
            it.unload();
          }
          this._registry.set(object.id(), object);
        }
      }.bind(this));
    },
    /**
     *  Registry#remove(object...) -> undefined
     *  - object (Object | Array): Single object, a list of objects or an
     *    array of objects to be removed from the registry.  The same objects
     *    as were provided to add to the registry must be provided here.
     *
     *  Remove an object from the registry, so that events do not get
     *  delegated to it if it is no longer on the page.
     **/
    remove: function() {
      var reg = this;
      var toAdd = (arguments.length > 1) ? Array.prototype.slice.call(arguments) : [arguments[0]].flatten();
      toAdd.each(function(object) {
        reg._registry.unset(object.id());
      });
    }
  }
});

// shortcut to build registry object
$Reg = function (hash, owner) {
  return new Registry({ initial: hash, owner: owner })
}

