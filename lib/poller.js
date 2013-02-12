JooseClass('Poller', {
  has: {
    on:          { is: 'ro', required: true },
    run:         { is: 'ro', required: true },
    timeout:     { is: 'ro' },
    onTimeout:   { is: 'ro' },
    context:     { is: 'ro' },
    elapsedTime: { is: 'rw' }
  },
  after: {
    initialize: function () {
      this.meta.getClassObject()._schedule(this);
    }
  },

  classMethods: {
    _schedule: function (poller) {
      var me = this;
      if(!this._runList) {
        this._runList = [];
      }
      if(!this._launcher) {
        this._launcher = new PeriodicalExecuter(function () {
            me._runList.each(function (runItem, index) {
              if(runItem) {
                if(runItem.on().apply(runItem.context())) {
                  me._runList.splice(index, 1);
                  runItem.run().apply(runItem.context());
                } else {
                  me._incrementElapsedTime(runItem, index);
                }
              }
            });
          }, 0.5);
      }
      this._runList.push(poller);
    },

    _incrementElapsedTime: function (runItem, index) {
      if(runItem.elapsedTime() !== undefined) {
        runItem.setElapsedTime(runItem.elapsedTime()+500);
        if(runItem.timeout() && runItem.elapsedTime() > runItem.timeout()) {
          this._runList.splice(index, 1);
          if(runItem.onTimeout()) {
            runItem.onTimeout().apply(runItem.context());
          }
        }
      } else {
        runItem.setElapsedTime(0);
      }
    }
  }
});