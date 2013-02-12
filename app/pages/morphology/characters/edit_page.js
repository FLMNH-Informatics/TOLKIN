//= require <page>
//= require <morphology/character>

JooseModule('Morphology.Characters', function () {
  JooseClass('EditPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Morphology Character: Edit'},
      height: { is: 'ro', init: 330 },
      width: { is: 'ro', init: 370 },
      savable: { is: 'ro', init: true },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'edit_project_morphology_character_path'
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
        me.notifier().working('Updating...');
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close();
            if (transport.responseJSON){
              var json = transport.responseJSON;
              if (json.msg.startsWith('Err')){
                me.notifier().error(json.msg);
              }else if (json.msg == 'old'){
                $$('.char_table')[0].replace(json.partial);
                me.frame().close();
                me.notifier().success('Character updated.');
              }else if (json.msg.startsWith('You')){
                me.notifier().warning(json.msg);
              }else{
                me.notifier().working('Character updated.');
                window.location = "/projects/" + params["project_id"] + "/morphology/characters/" + json.character.character.id.toString();
              }
            }
          },
          onFailure: function (transport) {
            me.frame().close();
            me.notifier().error("ERROR");
          }
        })
      }
    }
  })
})