//= require <templates/catalog>
//= require <templates/catalogs/filter_set>
//= require <molecular/insd/seq>
//= require "seq_catalogs/action_panel"

Module('Molecular.Insd.Seqs', function () {
  JooseClass('SeqCatalog', {
    isa: Templates.Catalog,
    has: {
      dataId: { is: 'ro', init: 'pk' },
      limit:  { is: 'ro', init: 10 },
      columns: { init: function () { return [
            { attribute: "organism",    width: 137 },
            { attribute: "markers_fulltext", label: "Markers",    width: 112 },
            { attribute: "sequence",  width: 152 } ] }},
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Molecular.Insd.Seqs.SeqCatalogs.ActionPanel({ parent: this }),
        filterSet:   new Templates.Catalogs.FilterSet({ parent: this, catalog: this/*, context: this.context()*/ })
      }, this ) } },
      canPublify: {init: false}
    },
    after: {
      initialize: function () {
        //todo this should maybe be in base catalog class, what else is the point of limits?
        this.collection().limit(this.limit()).select(this._selectArray());
      }
    }
  })
})

