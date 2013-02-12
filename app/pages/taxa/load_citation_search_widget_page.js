//= require <page>

JooseModule('Taxa', function () {
  JooseClass('LoadCitationSearchWidgetPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Citations Search' },
      htmlLoader: { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'load_citation_search_widget_project_taxon_path'
        }, this)
      } }
    },
    methods: {
//      onLoad: function () {
//        var me = this;
//        new Ajax.Request(this.route('load_citation_search_widget_project_taxon_path'), {
//          method: 'get',
//          onSuccess: function (transport) {
//            me._rendered = transport.responseText;
//            me.state().set('loaded');
//          }
//        });
//      },
      onClick: function (event) {
        Event.delegate({
//          NOT SAFE YET
//          '.div_citation_list': function () {
//            var id = event.element().upper('.div_citation_list').readAttribute('data-id')
//            this.frame().loadPage('project_library_citation_path', { id: id })
//          },
          '*[value="Create Citation"]': function (event) {
            this.frame().loadPage('new_project_library_citation_path');
          }
        }).bind(this)(event)
      },
      onSubmit: function (event) {
        var me = this;
        Event.delegate({
          '.citation_add': function (event) {
            event.stop();
            var fields = event.element().serialize({ hash: true, submit: false });
        
  
    //        var ids = [ fields['citation_ids[]'] ].flatten();
    //        var citations = ids.map(function (id) {
    //          var authors = $('cit_'+id).down('td:nth-child(2)').innerHTML;
    //          var year = $('cit_'+id).down('td:nth-child(3)').innerHTML;
    //          var title = $('cit_'+id).down('td:nth-child(4)').innerHTML;
    //          // add publication, type
    //          return {id:id, authors: authors, year: year, title: title , display_name : authors +" "+year+" "+title}
    //        })
            if(typeof fields["citation_ids[]"] != 'undefined'){
              new Ajax.Request(me.route('citation_add_project_taxon_path'), {
                parameters: fields,
                onSuccess: function (transport) {
                  var taxon = new Taxon({ id: me.params().id, context: me.context() });
                  taxon.fire('update', { memo: { record: taxon } })
                  taxon.unload()
                  me.frame().back();
      //            var atts = me.taxon().attributes();
      //            atts.citations = atts.citations ? atts.citations.concat(citations) : [citations].flatten();
      //            Windows.close("viewport_taxa_new_window", event);
                },
                onFailure: function () {
                  me.notifier().error('Could not add citations to taxon.')
                }
              });
            }else{
              alert('You must first select a citation')
            }
          }
        })(event);
      }

//      render: function () {
//        return this._rendered;
//      }
    }
  });
});
