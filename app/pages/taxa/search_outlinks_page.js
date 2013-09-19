//= require <page>
//= require <html_loader>

JooseModule('Taxa', function (){
  JooseClass('SearchOutlinksPage',{
    isa: Page,
    has: {
      canRender:  {is: 'ro', init: true },
      htmlLoader: {is: 'ro', init: function () {return $HtmlLoader({
        pathname: 'search_outlinks_project_taxon_path'
      }, this) } },
      title: {is: 'ro', init: "Search Outlinks"},
      savable: {is: 'ro', init: false},
      records: { is: 'ro', lazy: true, init: function () { return($Records({
              taxon: new Taxon({ id: this.context().params().id, context: this.frame().context()})
            }, this) ) } }
    },
    after:{
      onLoad: function (){this.notifier().success('Results loaded.')}
    },
    methods:{
      onClick: function (event){
        var taxon = this.record('taxon')
          , me = this;
        Event.delegate({
          '.select_outlink_taxon':function(event){
            var outlink_id = event.element().up('tr').dataset.outlinkId
              , outlink_type = event.element().up('tr').dataset.outlinkType
              , attrs = {
                  'ncbi':     {ncbi_id:     outlink_id},
                  'treebase': {treebase_id: outlink_id},
                  'ubio':     {ubio_id:     outlink_id},
                  'gbif':     {gbif_id:     outlink_id},
                  'eol':      {eol_id:      outlink_id}}
              , options = { onSuccess: function () { me.context().frame().loadPage('project_taxon_path', {id: taxon._id}); } };

            taxon.updateAttributes(attrs[outlink_type], options);
          },
          '.back_to_taxon': function (event){
            event.stop();
            me.context().frame().loadPage('project_taxon_path', {id: taxon._id})
          }
        }).bind(this)(event)
      }
    }
  })
})