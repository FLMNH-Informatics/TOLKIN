//= require <templates/auto_complete_field>

JooseModule('Otus', function () {
  JooseClass('ShowAddTaxonPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Otu : Add Taxon'},
      width: { is: 'ro', init: 350 },
      height: { is: 'ro', init: 330 },
      savable:       { is: 'ro', init: true },
      saveButtonText:{ is: 'ro', init: 'Add' },
      htmlLoader: { is: 'ro', init: function () { return $HTMLLoader({
        pathname: 'show_add_taxon_project_otu_path'
      }, this)}},
      widgets: { is: 'ro', init: function () { return $Widgets({
        auto_complete_field: new Templates.AutoCompleteField({
          parent: this.frame(),
          context: this.context(),
          object: new Otu({ id: this.params().id, context: this.context() }),
          method: 'taxon',
          valueMethod: 'taxon_id',
          textMethod:  'name',
          collection:
            Taxon.
              collection({ context: this.context() }).
              select('taxon_id', 'name').
              order('name')
        })
      }, this)} }
    },
    methods: {
      onClick: function (event) {
        Event.delegate({
          'input[type="button"][value="Add"]': function (event) {
            if ($('taxon_name_name_auto_input').value != "")
            {
              this.request(this.frame().element().down('form'))
            }
            else if ($("taxon_name_name_auto_input").value == "") {
              alert('You must choose a taxon')
            }
          }
        }).call(this, event)
      },
      onSubmit: function (event) {
        event.stop()
        this.request(event.element())
      },

      request: function (form) {
        var me = this
        this.notifier().working('Adding taxon to OTU ...')
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close()
            me.notifier().success('Taxon added successfully to OTU.')
            Otu.fire('recordUpdated', { id: me.params().id })            
            window.location = "/projects/" + params['project_id'] + "/otus/" + transport.responseJSON.id;
          }
        })
      }
    }
  })
})