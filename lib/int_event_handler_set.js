JooseClass('IntEventHandlerSet', {
  has: {
    owner:    { is: 'ro', required: true, nullable: false },
    handlers: { init: function () { return [] } },
    allDisabled: { is: 'ro', init: false }
  },
  methods: {
    allExpired: function () {
      return this.allDisabled()
    },

    enableAll: function () {
      this._handlers.each(function (h) { h.enable() })
      this._allDisabled = false
    },

    expireAll: function () {
      this._expireArray(this._handlers);
    },

    push: function () {
      this._handlers.push.apply(this._handlers, arguments);
    },

    _expireArray: function (array) {
      var me=this;
      array.each(function (item) {
        if(item.each) {
          me._expireArray(item);
        } else {
          item.expire();
        }
      });
      this._allDisabled = true
    }
  }
});

$Handlers = function (array, owner) {
  return new IntEventHandlerSet({ handlers: array, owner: owner })
}