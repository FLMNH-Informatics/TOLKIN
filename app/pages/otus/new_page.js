//= require <page>

JooseModule('Otus', function() {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'OTUs:  Add new OTU' },
      width: { is: 'ro', init: 600 },
      height: { is: 'ro', init: 250 },
      htmlLoader: { is:'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_otu_path'
      }, this) } }
    },
    methods: {
      onSubmit: function (event) {
        event.stop()
        var me = this
        this.notifier().working('Saving OTU...')
        //logic to save new OTU
        event.element().request({
          onSuccess: function () {
            me.notifier().success('OTU successfully created.')
            var otu = new Otu({ context: me.context() })
            otu.fire('create', { memo: { record: otu } })
            me.frame().close()
          },
          onFailure: function () {
            me.notifier().error('Problem encountered: OTU could not be created.')
         }
        })
      }
    }
  })
})