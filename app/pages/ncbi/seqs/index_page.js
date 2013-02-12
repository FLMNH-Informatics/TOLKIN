//= require <page>
//= require <widgets/ncbi/seqs/catalog>

JooseModule('Ncbi.Seqs', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      width:  {is: 'ro', init: 535 },
      height: { is: 'ro', init: 590 },
      title:  { is: 'ro', init: 'Import Sequences From NCBI' },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        catalog:  new Widgets.Ncbi.Seqs.Catalog({ context: this.context(), parent: this.frame() })
      }, this ) } },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'ncbi/seqs/index'
      ], this); }}
    },
    methods: {
      renderToString: function () {
        return this.context().templates().get('ncbi/seqs/index').evaluate({
          ncbi_sequences_catalog: this.widgets().get('catalog').renderToString()
        })
      }
    }
  })
});
