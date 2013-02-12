//= require <templates/catalog>
//= require <ncbi/seq>
//= require <ncbi/seqs/action_panel>

Module('Ncbi.Seqs', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      actionPanel:    { is: 'ro', init: function () { return new Ncbi.Seqs.ActionPanel({ context: this.context(), parent: this }) }},
      limit:          { is: 'ro', init: 20 },
      collectionName: { init: 'collections' },
      columns:        { init: function () { return(
                            [ { attribute: 'accession', width: 100 },
                              { attribute: 'description', width: 400 }
                            ]
                          )
                      }}
    },
    after: {
      initialize: function () {
        this.filters().load()
      }
    },
    override: {
      onRowClick: function (event) {
        var element = event.element();
          var id = element.up("div['data-id']").readAttribute('data-id');
          window.open('http://www.ncbi.nlm.nih.gov/nuccore/'+id,'_blank');
          //document.openInNewTab('http://www.ncbi.nlm.nih.gov/nuccore/'+id);
      }
    }
  })
});
