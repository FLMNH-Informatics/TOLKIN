//= require <roles/fires_events>

Role('Stateful', {
  does: Roles.FiresEvents,
  has: {
    states: { is: 'ro', init: function () { return new State([],this) } }
  },
  methods: {
    setState: function (state) {
      return this.states().set(state)
    },

    is: function (state) {
      return this.states().is(state)
    },

    not: function (state) {
      return this.states().not(state)
    }
  }
})