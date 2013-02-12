//= require <widget>
//= require "action_list"
//= require "versioning_action_list"


JooseModule('Molecular.Matrices', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    has: {
      widgets: { is: 'ro', init: function () { return $WSet({
        actionList: new Molecular.Matrices.ActionList({ context: this.context(), parent: this }),
        versioningActionList: new Molecular.Matrices.VersioningActionList({ context: this.context(), parent: this })
      }, this)}}
    }
  })
})