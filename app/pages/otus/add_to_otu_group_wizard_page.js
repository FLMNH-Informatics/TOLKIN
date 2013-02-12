//= require <page>

JooseModule('Otus', function () {
  JooseClass('AddToOtuGroupWizardPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: "OTUs : Add to OTU Group"},
      width: { is: 'ro', init: 450 },
      height: { is: 'ro', init: 160 },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'add_to_otu_group_wizard_project_otus_path',
        paramFunc: function () { return {
          conditions: this.params().conditions
        }}
      }, this) } }
    },
    methods: {
      onSubmit: function (event) {
        event.stop();
        var me = this;
        me.notifier().working('Adding OTU(s) to group')
        event.element().request({
          onSuccess: function () {
            me.notifier().success('OTU(s) successfully added to OTU Group.');
            Otu.fire('recordUpdated');
            me.frame().close();
          },
          onFailure: function () {
            me.notifier().error('Problem encountered: OTU(s) could not be added to OTU Group.');
          }
        })
      }
    }
  })
})