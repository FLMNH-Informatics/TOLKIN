JooseClass('IntEventHandler', {
  has: {
    obj:              { is: 'ro', required: true, nullable: false },
    eventName:        { is: 'ro', required: true, nullable: false },
    callback:         { is: 'ro', required: true, nullable: false },
    options:          { is: 'ro', init: function () { return {} } },
    context:          { is: 'ro', init: null },
    expired:          { is: 'ro', init: false },
    expiresAfterNext: { is: 'ro', init: false }
  },
  methods: {
    enable: function () {
      if(this.expired()) {

        this._expired = false
        this.obj().on(this.eventName(), this.callback(), Object.extend(this.options(), { handler: this }), this.context())
      }
    },
    disable: function () { return this.expire() },
    unset: function () { return this.expire() },
    expire: function () {
      this._expired = true;
    },

    expireAfterNext: function () {
      this._expiresAfterNext = true;
    }
  }
});