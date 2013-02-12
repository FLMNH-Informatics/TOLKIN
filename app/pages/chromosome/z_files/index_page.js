//= require <page>
//= require <chromosome/z_files/catalog>
//= require <chromosome/z_file>

Module('Chromosome.ZFiles', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        catalog: new Chromosome.ZFiles.Catalog({
          parent: this.frame(),
          collection: Chromosome.ZFile.collection({context: this.context()})
            .select('id','zvi_file_name','project_id', 'caption')
            .order('id')
            .limit(20)
        })
      }, this )}},
    templates: { is: 'ro', lazy: true, init: function () {
      return $Templates([
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'
        ], this )
      }}
    }
  })
});

