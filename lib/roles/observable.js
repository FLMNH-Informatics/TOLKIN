//= require "../exceptions/no_method_error"

/** section: Role
 *  mixin Observable
 *
 *  Mixin that allows an object to be observed per the observer design pattern.
 *  This class is a direct translation of the Ruby 1.9 Observable module.
 *
**/
Module('TOLJS.role', function() {
  Role('Observable', {
    methods: {
      /**
       *  Observable#addObserver(observer[, func = observer.update]) -> undefined
       *  - observer (Object): The object to be designated as observer.
       *  - func (Function): Function to call when `Observable` object is updated.
       *
       *  Subscribes observer object and function to `Observable` object.
      **/
      addObserver: function(observer, func) {
        if(!func) func = observer.update;
        if(!func) throw new TOLJS.Exception.NoMethodError("observer does not respond to 'update'");
        if(!this._observerPeers) this._observerPeers = $H();
        this._observerPeers.set(observer.id(), func.bind(observer));
        return this;
      },

      /**
       *  Observable#deleteObserver(observer) -> undefined
       *  - observer (Object): The observing object.
       *
       *  Removes as an observable the object provided.
      **/
      deleteObserver: function(observer) {
        if(this._observerPeers) this._observerPeers.unset(observer.id());
        return this;
      },

      /**
       *  Observable#deleteObservers() -> undefined
       *
       *  Removes every observer and listening function from this object.
      **/
      deleteObservers: function() {
        if(this._observerPeers) this._observerPeers.keys().each(function(key) {
          this._observerPeers.unset(key);
        });
        return this;
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
        return this;
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
          var outerArgs = arguments;
          this._observerPeers.each(function(pair) {
            pair.value.apply(null, outerArgs);
          });
        }
        this._observerState = false;
        return this;
      }
    }
  })
});
