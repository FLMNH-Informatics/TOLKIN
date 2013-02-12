//// don't init this class yourself.  go through uid provider - context().uids()
//JooseClass('Uid', {
//  has: {
//    provider: { is: 'ro', required: true, nullable: false },
//    value: { is: 'ro', required: true, nullable: false }
//  },
//  methods: {
//    destroy: function () {
//      this.provider().unregister(this.value())
//    },
//
//    toString: function () {
//      return this.value().toString()
//    }
//  }
//});