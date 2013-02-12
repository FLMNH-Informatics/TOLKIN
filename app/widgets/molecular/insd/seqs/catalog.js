//= require <templates/catalog>
//= require <templates/catalogs/filter_set>
//= require <molecular/insd/seq>
//= require "catalogs/action_panel"

Module('Molecular.Insd.Seqs', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      dataId: { is: 'ro', init: 'pk' },
      columns: { init: function () { return [
            { attribute: "organism",    width: 150 },
            { attribute: "markers_fulltext", label: "Markers",    width: 110 },
            { attribute: "locus",       width: 70 },
            { attribute: "definition",  width: 350 },
            { attribute: "sequence",    width: 350 }] }},
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Molecular.Insd.Seqs.Catalogs.ActionPanel({ parent: this }),
        filterSet:   new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context() })
      }, this ) } }
    },
    override: {
      onRowClick: function (event) {
        var seqId = event.element().up('.row').readAttribute('data-id');
        this.viewport().widget('window').loadPage('project_molecular_sequence_path', { id: seqId });
      }
    }
  })
});

