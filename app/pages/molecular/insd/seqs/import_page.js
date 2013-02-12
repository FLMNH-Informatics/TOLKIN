//= require <page>
////= require <molecular/insd/seq>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('ImportPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Import' },
      width: { is: 'ro', init: 490},
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_import_project_molecular_sequence_path'
      }, this)}},
      savable: { is: 'ro', init: true }
    },
    methods: {
      onSubmit: function (event) {
        event.stop();
        var me = this;
        me.notifier().working('Importing sequence ...');
        event.element().request({
          onSuccess: function () {
            me.notifier().success('Successfully imported sequence');
            //new Molecular.Insd.Seq({ context: me.context() }).fire('create')
            me.frame().close();
          },
          onFailure: function () {
            me.notifier().error("Problem importing sequence.");
          }
        })
      }
    }
  })
})