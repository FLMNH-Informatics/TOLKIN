//= require <widget>
//= require "action_list"


JooseModule('OtuGroups', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    has: {
      widgets: { is: 'ro', init: function () { return $WSet({
        actionList: new OtuGroups.ActionList({ context: this.context(), parent: this })
      }, this)}}
    }
  })
})