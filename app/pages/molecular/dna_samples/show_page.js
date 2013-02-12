//= require <page>
//= require <forms_helper>
//= require <molecular/dna_samples/taxon_combo_box>
//= require <molecular/dna_samples/collection_combo_box>
//= require <molecular/dna_samples/catalog>
//= require <molecular/dna_samples/user_panel>

Module('Molecular.DnaSamples', function() {
  JooseClass('ShowPage', {
    isa: Page,
    does: [FormsHelper],
    has: {
      title:      { is: 'ro', init: 'DNA Sample : Show' },
      width:      { is: 'ro', init: 1000 },
      height:     { is: 'ro', init: 456 },
      savable:    { is: 'ro', init: true },
      canRender:  { is: 'ro', init: true },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: "project_molecular_dna_sample_path"
      }, this) }},
      records:    { is: 'ro', lazy: true, init: function () { return $Records({
        dnaSample: new Molecular.DnaSample({ id: this.context().params().id, context: this.frame().context() })
      }, this )}},
      widgets:    { is: 'ro', lazy: true, init: function () {
          return $WSet({
            taxonComboBox:
            new Molecular.DnaSamples.TaxonComboBox({
              parent: this.frame(),
              object: this.records().get('dnaSample')
            }),
            collectionComboBox:
            new Molecular.DnaSamples.CollectionComboBox({
              parent: this.frame(),
              object: this.records().get('dnaSample')
            })
          }, this )
        }
      },
      templates: {
        is: 'ro',
        lazy: true,
        init: function () {
          return $TSet([
            'filters/_form',
//            'layouts/window',
            'widgets/_catalog'
//            'widgets/catalogs/_entry'
//            'molecular/dna_samples/_dna_details'
            //'molecular/dna_samples/catalogs/_action_panel'
          ], this )
        }
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
    },
    methods :{
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            var form = event.element().up('.dialog').down('.edit_molecular_dna_sample');
            var id = me.context().params().id
            //form.submit();
          
            form.request({
              method: 'post',
              onSuccess: function () {
                me.notifier().success('DNA Sample saved successfully.');
                //new Molecular.DnaSample({ context: me.context() }).fire('create')
                //me.record('dnaSample').fire('update', { memo: { record: me.record('dnaSample') } })
                //var dnaSampleId = event.element().up('*[data-id]').readAttribute('data-id');
                me.frame().loadPage('project_molecular_dna_sample_path', { id: id })
              }
            });
          }
        })(event);
      }
    }
  })
});
