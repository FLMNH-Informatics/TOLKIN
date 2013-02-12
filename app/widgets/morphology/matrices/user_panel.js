//= require <widget>
//= require "action_list"
//= require "versioning_action_list"


JooseModule('Morphology.Matrices', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    has: {
      context: { is: 'ro', required: true, nullable: false },
      widgets: { is: 'ro', init: function () { return( $Reg({
        actionList: new Morphology.Matrices.ActionList({context: this.context(), parent: this}),
        versioningActionList: new Morphology.Matrices.VersioningActionList({ context: this.context(), parent: this })
      }, this) )}}
    }
  })
})

