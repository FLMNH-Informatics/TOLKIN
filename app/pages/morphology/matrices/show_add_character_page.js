//= require <page>
//= require <html_loader>
//= require <morphology/matrix>
//= require <morphology/matrices/character_name_auto_text_field>

JooseModule('Morphology.Matrices', function () {
  JooseClass('ShowAddCharacterPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 400 },
      width:          { is: 'ro', init: 500 },
      title:          { is: 'ro', init: "Matrix:  Add Character"},
      records:        { is: 'ro', lazy: true, init: function () { return $Records({
            matrix: new Morphology.Matrix({ context: this.context(), data: {} })
      }, this)} },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Add Character'},
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_character_project_morphology_matrix_path'
      }, this ) } },
      widgets:        { is: 'ro', init: function () { return $Widgets({
        characterNameField: new Morphology.Matrices.CharacterNameAutoTextField({
          object: this.record('character'),
          parent: this.frame()
        })
      }, this )}}
    },
    methods: {
      onClick: function (event) {
        Event.delegate({
          'input[type="button"][value="Add Character"]': function (event) {
            this.request(this.frame().element().down('form'))
          }
        }).call(this, event)
      },
      onSubmit: function (event) {
        event.stop()
        this.request(event.element())
      },
      request: function (form) {
        var me = this
        this.notifier().working('Adding character(s) to matrix')
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close()
            if (transport.responseJSON){
              if (transport.responseJSON.message) {me.notifier().error(transport.responseJSON.message)}
              else {
                $('form_character_list').replace(transport.responseJSON.char_list)
                me.notifier().success('Character(s) successfully added to matrix.')}
            }
          }
        })
      }
    }
  })
})