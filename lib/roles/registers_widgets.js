//= require <registry>

JooseModule('TOLJS.role', function () {
  JooseRole('RegistersWidgets', {
    has: {
      widgets: { is: 'ro', lazy: true, init: function () { return new Registry({ owner: this }) } }
    },
    methods: {
      addWidget: function (widget) {
        return this.widgets().add(widget);
      },

      addWidgets: function (widgets) {
        return this.widgets().add(widgets);
      }
    }
  });
});