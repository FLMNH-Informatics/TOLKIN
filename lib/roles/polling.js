//= require <poller>

Role('Polling', {
  methods: {
    poll: function (options) {
      return new Poller(Object.extend({ context: this }, options));
    }
  }
});