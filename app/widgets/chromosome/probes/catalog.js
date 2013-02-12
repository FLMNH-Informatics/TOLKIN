//= require <templates/catalog>
//= require <templates/catalogs/filter_set>
//= require <chromosome/probe>
//= require "catalogs/action_panel"

JooseModule('Chromosome.Probes', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      dataId: { is: 'ro', init: 'id' },
      columns: { init: function () { return [ 
            { attribute: "value", width: 120 },
            { attribute: 'scaffold_id', width: 120 },
            { attribute: 'chromosome',  width: 150 },
            { attribute: 'genome_builder_super_scaffold',  width: 170 },
            { attribute: 'probe_type',  width: 100 } ] }},
      width: { init: 690},
      showFiller: { is: 'ro', init: false},
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Chromosome.Probes.Catalogs.ActionPanel({ parent: this }),
        filterSet:   new Templates.Catalogs.FilterSet({ parent: this, catalog: this })
      }, this ) } }

    },
    override: {
      onRowClick: function (event) {
        var probeId = event.element().up('.row').readAttribute('data-id');
        this.viewport().widget('window').loadPage('project_chromosome_probe_path', { id: probeId })
        //window.location = this.route('project_chromosome_probe_path', { id: probeId })
        //this.designatedFrame().loadPage('project_molecular_sequence_path', { id: seqId });
        //window.location.pathname = this.context().routes().pathFor('project_sequence_path', { id: seqId });
      }
    }
  })
});