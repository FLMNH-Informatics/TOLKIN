//= require <page>
//= require <html_loader>
//= require <morphology/character>

JooseModule('Morphology.Characters', function () {
  JooseClass('AddToGroupPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      height: { is: 'ro', init: 250 },
      width: { is: 'ro', init: 460},
      title: { is: 'ro', init: "Characters: Add to Group"},
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'add_to_group_project_morphology_characters_path',
          paramFunc: function () { return {
            conditions: this.params().conditions
        }}
      }, this) } }
    },
    methods: {
      onSubmit: function (event) {
        event.stop()
        var me = this
        this.notifier().working('Adding Characters to group ...')
        event.element().request({
          onSuccess: function () {
            me.notifier().success('Character(s) successfully added to group')
            Morphology.Character.fire('recordUpdated')
            // Creating new otu without storing so it can later have unload called results in unnecessary ajax call propagation
//            var otu = new Otu({ context: me.context() })
//            otu.fire('update', { memo: { record: otu } }) // update underlying catalog if there
            me.frame().close()
          },
          onFailure: function () {
            me.notifier().error('Problem encountered: Characters could not be added to Character Group.')
          }
        })
      }
    }
  })
})