//= require <page>
//= require <molecular/dna_sample>
//= require <molecular/dna_samples/catalog>
//= require <molecular/dna_samples/user_panel>

Module('Molecular.DnaSamples', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//      records: { is: 'ro', lazy: true, init: function () { return $RSet({
////        dnaSamples: Molecular.DnaSample.collection({ context: this.frame().context() })
//      }, this ) }},
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
          userPanel:  new Molecular.DnaSamples.UserPanel({ parent: this.frame().viewport() }),
          catalog: 
            new Molecular.DnaSamples.Catalog({
              parent: this.frame(),
              collection: Molecular.DnaSample.collection({ context: this.frame().context() })
            })
      }, this ) } },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
          'filters/_form',
          'layouts/window',
          'widgets/_catalog',
          'widgets/catalogs/_entry',
          'molecular/dna_samples/_dna_details'
          //'molecular/dna_samples/catalogs/_action_panel'
        ], this ) } } } }) });
