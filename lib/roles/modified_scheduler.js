//= require <queue>

JooseModule('Roles', function () {
  JooseRole('ModifiedScheduler', {
    has: {
      afterSchedule: { }
    },
    methods: {
      before: function () { alert('NOT YET IMPLEMENTED'); },
      after: function (args, context) {
        var it;
        this._afterSchedule || (this._afterSchedule = {});
        if(typeof args == 'string') {
          if((it = this._afterSchedule[args])) { it.flush(); }
        } else if(typeof args == 'object') {
          $H(args).each(function (pair) {
            var funcName = pair.key;
            var func = pair.value;
            if(context) { func = func.bind(context) }
            this._afterSchedule[funcName] || (this._afterSchedule[funcName] = new Queue());
            this._afterSchedule[funcName].add(func);
          }, this);
        }
      }
    }
  })
});