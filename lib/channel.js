//JooseClass('Channel', {
//  has: {
//    owner:     { is: 'ro' },
//    name:      { is: 'ro', required: true, nullable: false },
//    listeners: { is: 'ro', init: function () { return $H() }}
//  },
//  methods: {
//    receiveMessage: function (message) {
//      this.listeners().values().each(function (listener) { listener.receiveMessage(message, this) });
//    },
//
//    addListener: function (listener) {
//      this.listeners().set(listener.uid(), listener);
//    },
//
//    addListeners: function (listeners) {
//      listeners.each(function(listener) { this.addListener(listener) })
//    }
//  }
//})