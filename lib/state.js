JooseClass('State', {
  has: {
    owner: { is: 'ro' },
    stateLookup: { }
  },
  methods: {
    initialize: function (statesArr, owner) {
      this._stateLookup = {};
      this._owner = owner;
      statesArr.each(function (stateSetArr) {
        var valHolder = {};
        stateSetArr.each(function (state) {
          this._stateLookup[state] = valHolder;
        }, this);
      }, this);
    },
    set: function (state) {

      if(!(this._stateLookup[state].state == state)) {
        var prevState = this._stateLookup[state].state
        this._stateLookup[state].state = state;
        this._owner.fire(state, { memo: prevState });
      }
    },
    is: function () {
      var args = [].slice.call(arguments);
      return args.all(function (n) { return(this._stateLookup[n].state == n); }, this);
    },
    not: function () {
      return !this.is.apply(this, arguments);
    }
  }
// write a custom initializer here
});

function $States (states, context) {
  return new State(states, context)
}
