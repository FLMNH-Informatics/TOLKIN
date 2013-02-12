////= require <templates/window>
////= require <roles/polling>
////= require <taxon>
////= require <taxa/parent_combo_box>
////= require <taxa/accepted_name_combo_box>
//
//Module('Taxa', function () {
//  JooseClass('NewWindow', {
//    isa: Templates.Window,
//    does: Polling,
//    has: {
//      title: { is: ro, init: 'New Taxon Window' },
//      taxon: { is: 'ro' },
//      widgets: { is: 'ro', init: function () { return $Reg({
//        parentComboBox: new Taxa.ParentComboBox({
//          parent: this,
//          taxon: new Taxon({ context: this.context() })
//        }),
//        acceptedNameComboBox: new Taxa.AcceptedNameComboBox({
//          parent: this,
//          context: this.context(),
//          taxon: new Taxon({context: this.context() })
//        })
//      }, this)}}
//    },
//    methods: {
//      onSubmit: function (event) {
//        if(event.element().hasClassName('new_citation')){
//         var fields = event.element().serialize({ hash: true, submit: false });
//         //var iframe_body = $('upload_frame').document().createElement('body');
////         var iframe_span = $('upload_frame').document().createElement('span');
////         iframe_span.setAttribute('id', 'citation_status');
////         $('upload_frame').document().body.appendChild(iframe_span);
//         //$('upload_frame').document().firstChild.appendChild(iframe_body);
//          this.poll({
//            on: function () { return $('upload_frame').$('citation_status') },
//            run: function() { this._appendNewCitation(fields); Windows.close("viewport_taxa_new_window", event) }
//          })
//        }
//      },
//
//      _appendNewCitation: function (fields){
//         if($('upload_frame').$('citation_status').innerHTML == 'success'){
//           var evaledTemplate = $('upload_frame').$('citation_list_insert').innerHTML;
//           $('div_taxon_'+this.taxon().id()+'_citations').insert({ bottom: evaledTemplate });
//              var authors = $('upload_frame').$('new_citation_authors').innerHTML;
//              var id = $('upload_frame').$('new_citation_id').innerHTML;
//              var citation = {
//                          id: id,
//                     authors: authors,
//                        year: fields['citation[year]'],
//                       title: fields['citation[title]'] ,
//                display_name: authors +" "+ fields['citation[year]'] +" "+ fields['citation[title]']
//              }
//              var atts = this.taxon().attributes();
//              atts.citations = atts.citations ? atts.citations.concat(citation) : [citation].flatten();
//         }
//      },
//      onClick: function (event) {
//         Event.delegate({
//          '.ubio_select':function(event){
//            this.loadTaxonomyFromUbio(event.element().value);
//            $('viewport_window_taxa_tabbed_box_taxa_taxon_outlinks_table').down("input[name='taxon[ubio_id]']").value = event.element().value;
//           },
//          'ubio_final_selection':function(event){
//
//          },
//          '.treeBase_select':function(event){
//            //this.loadTaxonomyFromTreeBase(event.element().value);
//            $('viewport_window_taxa_tabbed_box_taxa_taxon_outlinks_table').down("input[name='taxon[treebase_id]']").value = event.element().value;
//           },
//          '.ncbi_select':function(event){
//            this.loadTaxonomyFromNcbi(event.element().value);
//            $('viewport_window_taxa_tabbed_box_taxa_taxon_outlinks_table').down("input[name='taxon[ncbi_id]']").value = event.element().value;
//           }
//         }).bind(this)(event);
//      },
//      loadContents: function() {
//        var window = this
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/new', {
//          method: 'get',
//          onSuccess: function(transport) {
//            window.render({yield: transport.responseText});
//            window.display();
//          }
//        });
//      },
//      searchUbio: function(name) {
//        var window = this
//        //alert(Object.keys(params));
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/ubio_search', {
//          parameters: { name: name},
//          method: 'get',
//          onSuccess: function(transport) {
//            window.render({yield: transport.responseText});
//            window.display();
//          }
//        });
//      },
//      searchTreeBase: function(name) {
//        var window = this
//        //alert(Object.keys(params));
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/treebase_search', {
//          parameters: { name: name},
//          method: 'get',
//          onSuccess: function(transport) {
//            window.render({yield: transport.responseText});
//            window.display();
//          }
//        });
//      },
//      searchNcbi: function(name) {
//        var window = this
//        //alert(Object.keys(params));
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/ncbi_search', {
//          parameters: { name: name},
//          method: 'get',
//          onSuccess: function(transport) {
//            window.render({yield: transport.responseText});
//            window.display();
//    }
//        });
//      },
//      loadTaxonomyFromUbio: function(id) {
//        var window = this
//        //alert(Object.keys(params));
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/ubio_retrieve_taxon_details', {
//          parameters: { ubio_id: id},
//          method: 'get',
//          onSuccess: function(transport) {
//            Element.update($('window_taxon_description'), transport.responseText);
//
//          }
//        });
//      },
//      loadTaxonomyFromNcbi: function(id) {
//        var window = this
//        //alert(Object.keys(params));
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/ncbi_retrieve_taxon_details', {
//          parameters: { ncbi_id: id},
//          method: 'get',
//          onSuccess: function(transport) {
//            Element.update($('window_taxon_description'), transport.responseText);
//
//          }
//        });
//      },
//      loadTaxonomyFromTreeBase: function(id) {
//        var window = this
//        //alert(Object.keys(params));
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/treebase_retrieve_taxon_details', {
//          parameters: { ncbi_id: id},
//          method: 'get',
//          onSuccess: function(transport) {
//            Element.update($('window_taxon_description'), transport.responseText);
//
//          }
//        });
//      },
//      loadCitationSearch: function(id) {
//        var window = this
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/load_citation_search_widget', {
//          parameters: { id: id},
//          method: 'get',
//          onSuccess: function(transport) {
//            window.render({yield: transport.responseText});
//            window.display();
//          }
//        });
//      }
//    }
//  })
//});
