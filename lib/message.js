JooseClass('Message', {
  has: {
    sender: { is: 'ro', required: true, nullable: false },
    receiver: {},
    receivers: {},
    channel: {},
    channels: {}
  },
  after: {
    initialize: function () {
      if([ this._receiver, this._receivers, this._channel, this._channels ].compact().size() != 1) {
        throw('provided more than one of the following: receiver, receivers, channel, channels');
      }
      this._receivers = [ this._reciever || this._receivers || this._channel || this._channels ].flatten(); // consolidate into receivers
    }
  },
  methods: {
    send: function () {
      this._receivers.each(function (receiver) {
        receiver.receiveMessage(this)
      }, this)
    },
    type: function () {
      return this.meta.getClassObject();
    }
  }
});