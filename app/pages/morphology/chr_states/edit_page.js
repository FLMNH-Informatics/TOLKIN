//= require <page>
//= require <html_loader>

JooseModule('Morphology.ChrStates', function () {
  JooseClass('EditPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Morphology Character State: Edit'},
      height: { is: 'ro', init: 330 },
      width: { is: 'ro', init: 370 },
      savable: { is: 'ro', init: true },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'edit_project_morphology_character_chr_state_path'
      }, this)}}
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.button.active.saveButton': function(){
            var form = $('viewport_window_content').down('form')
              , table = $('chr_state_table_' + params["id"]);
            me.notifier().working('Updating character state...');
            form.request({
              requestHeaders: ['Accept', 'application/json'],
              parameters: {"matrix_id": params["matrix_id"] || ""},
              onSuccess: function (transport) {
                if (transport.responseJSON.msg == 'ok'){
                  table.replace(transport.responseJSON.partial);
                  me.notifier().success('Character state updated.')
                  me.frame().close();
                }else if (transport.responseJSON.msg == "new"){
                  window.location = "/projects/" + params["project_id"] + "/morphology/characters/" + transport.responseJSON.character_id.toString();
                }else{
                  me.frame().close();
                  me.notifier().error('Error: ' + transport.responseJSON.msg.toString());
                }
              },
              onFailure: function (transport) {
                me.frame().close();
                me.notifier().error('Something went wrong.');
              }
            })
          }
        }).call(this,event)
      }
    }
  })
})