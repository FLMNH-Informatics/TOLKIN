//= require <page>
//= require <chromosome/probes/catalog>
//= require <chromosome/probe>

JooseModule('Chromosome.Probes', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        catalog: new Chromosome.Probes.Catalog({
          parent: this.frame(),
          collection: Chromosome.Probe
          .collection({ context: this.context() })
        })
      }, this )  }},
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'
      ], this )  } }
    }
  })
});

