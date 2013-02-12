JooseModule('TOLJS.role', function () {
  JooseRole('Context', {
    requires: [ 'notifier', 'routes', 'path', 'templates' ]
  })
});