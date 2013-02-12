//= require <page>
//= require <otu_group>
//= require <html_loader>

JooseModule('OtuGroups', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      savable: { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Create' },
      width: { is: 'ro', init: 400 },
      height: { is: 'ro', init: 150 },
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'New Otu Group' },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'otu_groups/_new_otu_group'
      ], this) } },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_otu_group_path'
      }, this) }}
    },
    methods:{
      onClick: function(event){
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            me.notifier().working('Creating OTU Group ...');
            $(me.frame().id()).down('form').request({
              requestHeaders: { Accept: 'application/json' },
              onSuccess: function (transport) {
                me.notifier().success('OTU Group created.');
                OtuGroup.fire('recordUpdated')
                //me.frame().loadPage('project_otu_group_path', { id: transport.responseJSON.otu_group.id })
                me.frame().close()
              }
            })
          }
        }).call(this, event)
      }

    }
  })
})
