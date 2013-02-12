//= require <page>
//= require <html_loader>
//= require <morphology/character>

JooseModule('Morphology.Characters', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Character : New' },
      height: { is: 'ro', init: 350 },
      width: { is: 'ro', init: 700 },
      savable: { is: 'ro', init: true },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_morphology_character_path'
      }, this)}}
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.button.active.saveButton': function(){
            var form = $('viewport_window_content').down('form');
            me.request(form);
          }
        }).call(this,event)
      },
      request: function (form) {
        var me = this;
        me.notifier().working('Saving new character...');
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close();
            if (transport.responseJSON){
              me.notifier().working('Character created.')
              window.location = window.location.href + '/' + transport.responseJSON.character.id.toString();
            }
          },
          onFailure: function (transport) {
            me.frame().close();
            me.notifier().error("ERROR");
          }
        })
      }
//      onSubmit: function (event) {
//        event.stop()
//        var me = this
//        me.notifier().working('Saving new character ...')
//        event.element().request({
//          onSuccess: function () {
//            me.notifier().success('Successfully created new character.')
//            new Morphology.Character({ context: me.context() }).fire('create')
//            me.frame().close()
//          },
//          onFailure: function () {
//            me.notifier().error("Problem creating new character.")
//          }
//        })
//      }
    }
  })
})