//= require <widgets/templates/tooltip>

JooseModule('General', function () {
  JooseClass('MouseTooltip', {
    isa: Templates.Tooltip,
    has: {
      insertUnder: { init: 'viewport' }
    },
    after: {
      initialize: function () {
        var me = this;
        this.hide();
        Event.observe(document, 'mousemove', function (event) {
          me.move(event.pointer());
        });
      }
    }
  });
});