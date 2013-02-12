//= require <templates/catalog>
//= require <molecular/dna_sample>
//= require "window"
//= require <molecular/dna_samples/catalogs/action_panel>

Module('Molecular.DnaSamples', function() {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
       //collectionName: { init: 'molecular::dna_samples'},
       collectionClass: { is: 'rw', init: function () { return Molecular.DnaSample } },
       collection: { is: 'ro', required: true, nullable: false },
//       collection: { is: 'ro', init: function () {
//          return Molecular.DnaSample.collection({ context: this.context() })
//        }},
       columns: { init: function() { return [
         { attribute: "taxon.taxon.label", label: "Taxon", width: 450 },
         { attribute: "collection.collection.label", label: "Voucher", width: 200 }
       ]}},
       widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Molecular.DnaSamples.Catalogs.ActionPanel({ parent: this }),
        filterSet: new Templates.Catalogs.FilterSet({context: this.context(), parent: this, catalog: this})
      }, this) } }
    },
    override: {
      onRowClick: function(event) {
//        if(this._inARow(event.element())) {
        var dnaSampleId = event.element().up('*[data-id]').readAttribute('data-id');
        this.viewport().widget('window').loadPage('project_molecular_dna_sample_path', { id: dnaSampleId })
//        var dnaSampleDetailsWindow = new Molecular.DnaSamples.Window({ context : this.context(), parent : this.viewport(), dnaSample : new Molecular.DnaSample({id : dnaSampleId, context : this.context()})});
//        this.viewport().widgets().add(dnaSampleDetailsWindow);
//        dnaSampleDetailsWindow.loadContents({
//          onSuccess: function () { dnaSampleDetailsWindow.render().display() }
//        });
        //          var taxonWindow = new TaxonDetailsWindow('taxon_details_window', new Taxon(taxonId));
        //          taxonWindow.taxon.loadAttributes({
        //            callback: taxonWindow.render.bind(taxonWindow)
        //          });
//        }
      },
      onClick: function(event) {
        Event.delegate({
          '.add_new_entry_control': function(event) {
            var window = new Molecular.DnaSamples.Window('dna_sample_details_window');
            window.loadContents({
              onSuccess: window.render.bind(window)
            });
          },
          'html': this.SUPER(event)
        }).bind(this)(event);
      }
    }
  })
});
