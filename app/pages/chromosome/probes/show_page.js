//= require <page>
//= require <chromosome/probe>

JooseModule('Chromosome.Probes', function () {
  JooseClass('ShowPage', {
    isa: Page,
    has: {
        savable:   { is: 'ro', init: true },
        canRender: { is: 'ro', init: true },
        title:     { is: 'ro', init: 'Show Probe'},
        height:    { is: 'ro', init: 450 },
        width:     { is: 'ro', init: 815 },
        records: { is: 'ro', lazy: true, init: function () { return $Records({
            probe: new Chromosome.Probe({ id: this.params().id, context: this.context() })
        }, this) } },
        htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
          pathname: 'project_chromosome_probe_path',
          paramFunc: function () { return {
            interact_mode: this.interactMode().get(),
            noJSON: 'true'
          }}
        }, this)} },
        templates: { is: 'ro', lazy: true, init: function () { return $Templates([
          'widgets/_catalog',
          'widgets/catalogs/_entry',
          'filters/_form'
        ], this )}}},
    methods: {
      onClick: function(event) {
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event){
            this.notifier().working('Saving ...');
            var form = $(this.frame().id()).down('.edit_chromosome_probe')
            form.request({
              onSuccess: function () {
                me.notifier().success('Probe saved successfully.');
                me.record('probe').fire('update', { memo: { record: me.record('probe') } })
              }
            });
          }
        }).call(this,event)
      }
    }
  })
})
