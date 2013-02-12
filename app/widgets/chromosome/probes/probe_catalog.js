//= require <templates/catalog>
//= require <templates/catalogs/filter_set>
//= require <chromosome/probe>


Module('Chromosome.Probes', function () {
  JooseClass('ProbeCatalog', {
    isa: Templates.Catalog,
    has: {
      dataId: { is: 'ro', init: 'id' },
      limit:  { is: 'ro', init: 10 },
      columns: { init: function () { return [
        { attribute: "value",             width: 150 },
        { attribute: 'scaffold_id',       width: 120 },
        { attribute: 'chromosome',        width: 150 },
        { attribute: 'genome_builder_super_scaffold',  width: 170 },
        { attribute: 'probe_type',        width: 100 } ] }},
      widgets: { is: 'ro', init: function () { return $Reg({
        filterSet:   new Templates.Catalogs.FilterSet({ parent: this, catalog: this })
      }, this ) } }
    },
    after: {
      initialize: function () {
        //todo this should maybe be in base catalog class, what else is the point of limits?
        this.collection().limit(this.limit()).select(this._selectArray());
      }
    },
    override: {
      onRowClick: function (event) {
        if (this.interactMode()._value == 'edit'){
          if (confirm("Do you want to attach this probe to the ZVI file?")){
            var probeId = event.element().up('.row').readAttribute('data-id');
            this.parent().page().attachProbe(probeId);
          }
        }
      }
    }
  })
})

