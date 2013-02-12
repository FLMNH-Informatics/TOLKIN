//= require 'sync_collection'

JooseClass('EmptyCollection', {
  isa: SyncCollection,
  has: {
    data: { is: 'ro', init: function () { return [] }}
  },
  after: {
    initialize: function () {
      this.state().set('loaded')
    }
  },
  methods: {
    load: function () { }
  }
})