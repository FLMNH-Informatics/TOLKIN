//= require <page>
//= require <chromosome/probe>
//= require <forms_helper>

JooseModule('Chromosome.Probes', function () {
  JooseClass('NewPage', {
    isa: Page,
    does: FormsHelper,
    has: {
      canRender:  { is: 'ro', init: true },
      title:      { is: 'ro', init: 'Create Probe' },
      height:     { is: 'ro', init: 600 },
      width:      { is: 'ro', init: 410 },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_chromosome_probe_path'
      }, this)}}},
    methods: {
      onSubmit: function(event) {
        event.stop();
        var me = this;
        me.notifier().working('Creating probe...')
        event.element().request({
          requestHeaders: { Accept: 'application/json' },
          onSuccess: function () {
            var probe = new Chromosome.Probe({ context: me.context() });
            probe.fire('create', { memo: { record: probe } });
            me.frame().close();
            me.notifier().success('Probe successfully created!');
          },
          onFailure: function (transport) {
            var response = transport.responseText;
            me.notifier().failure(response);
          }
        })
      }
    }
  });
});