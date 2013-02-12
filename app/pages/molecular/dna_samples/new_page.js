//= require <page>
//= require <molecular/dna_sample>
//= require <forms_helper>

Module('Molecular.DnaSamples', function () {
  JooseClass('NewPage', {
    isa: Page,
    does: [FormsHelper],
    has: {
      savable:      { is: 'ro', init: true},
      canRender:    { is: 'ro', init: true },
      width:        { is: 'ro', init: 1000 },
      height:       { is: 'ro', init: 445 },
      collection:   { is: 'rw'},
      title:        { is: rw, init: 'New Raw Dna Sample', nullable: false },
      htmlLoader:   { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'new_project_molecular_dna_sample_path'
        }, this)
      }},
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        taxonComboBox:
        new Molecular.DnaSamples.TaxonComboBox({
          parent: this.frame(),
          context: this.context(),
          object: new Molecular.DnaSample({ context: this.frame().context() })
        }),
        collectionComboBox:
        new Molecular.DnaSamples.CollectionComboBox({
          parent: this.frame(),
          context: this.context(),
          object: new Molecular.DnaSample({ context: this.frame().context() })
        })
      }, this)} }
    },
    methods:{
      requestForm: function (form) {
        var me = this
        this.notifier().working('Creating DNA sample ... ')
        form.request({
          requestHeaders: { Accept: 'application/json' },
          onSuccess: function (transport) {
            me.notifier().success('DNA sample created.')
            new Molecular.DnaSample({ context: me.context() }).fire('create')
            me.frame().loadPage('project_molecular_dna_sample_path', { id: transport.responseJSON.dna_sample.id }) //close ? me.frame().close() : me.frame().back()
          },
          onFailure: function (transport) {
            me.notifier().error('Create failed: problem creating DNA sample.')
          }
        })
      },

      onSubmit: function (event) {
        event.stop()
        this.requestForm(event.element())
      },

      onClick: function (event){
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            event.stop()
            me.requestForm($('new_molecular_dna_sample'))
            //me.requestForm($(me.frame().id().down('form')))
          }
        }).call(this, event)
      }
    },
    after: {
      initialize: function () {
        this.handlers().push(
          this.frame().on('state:displayed', function () {
            if(this.frame().is('pageRendered')) {
              this.dateFieldInit('date_received')
              this.dateFieldInit('date_extracted')
        }
          }, this)
        )
      }
    }
  })
});
