//= require <page>
//= require <html_loader>
//= require <otu_group>
//= require <otu_groups/otu_name_auto_text_field>

JooseModule('OtuGroups', function () {
  JooseClass('ShowAddOtuPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 320 },
      width:          { is: 'ro', init: 360 },
      title:          { is: 'ro', init: "OTU Group:  Add OTU"},
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Add OTU'},
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_otu_project_otu_group_path'
      }, this ) } },
      widgets:        { is: 'ro', init: function () { return $Widgets({
        otuNameField: new OtuGroups.OtuNameAutoTextField({
          object: this.record('otu'),
          parent: this.frame()
        })
      }, this )}},
      records: { is: 'ro', lazy: true, init: function () {
          return ($Records({
            otuGroup: new OtuGroup({ context: this.frame().context(), id: this.context().params().id })
          }, this))}}
    },
    methods: {
      onClick: function (event) {
        Event.delegate({
          'input[type="button"][value="Add OTU"]': function (event) {
            this.request(this.frame().element().down('form'));
          }
        }).call(this, event);
      },
      onSubmit: function (event) {
        event.stop();
        this.request(event.element());
      },
      request: function (form) {
        var me = this;
        this.notifier().working('Adding OTU(s) to group');
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close();
            if (transport.responseJSON){
              if (transport.responseJSON.message){
                me.notifier().error(transport.responseJSON.message);
              }else{
                $('otus_list').insert({bottom: transport.responseJSON.otu_row})
                me.notifier().success('OTU(s) successfully added to matrix.')
              }
            }
            else{
              me.notifier().success('OTU(s) successfully added to matrix.');
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
});