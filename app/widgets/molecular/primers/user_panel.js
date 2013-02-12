//= require <widget>
//= require "action_list"

Module('Widgets.Molecular.Primers', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    has: {
      widgets: { is: 'ro', init: function () { return(
          $Reg({
            actionList: new Widgets.Molecular.Primers.ActionList({ parent: this })
          }, this)
        )
        }}
    }
  })
});
