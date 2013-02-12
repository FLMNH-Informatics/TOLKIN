//= require <widgets/templates/tooltip>
//= require <widget>
//= require <templates/action_panel>

Module('Library.Citations.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has:{
        catalog: { is: 'ro', init: function(){ return this.parent(); } },
        collection_view: { is: 'ro', init: function () { return this.parent() } },
        buttons: {
          is: 'ro',
          init: [
            { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
            { label: 'Bulk Upload', img: { src: "/images/sm_upload.png" }, imode: 'edit'},
            { label: 'Citations Search', img: { src: "/images/small_search.png" }, imode: [ 'edit', 'browse' ] }
          ]
        }
    },

    methods: {

      onClick: function(event) {
        var me = this;
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Create':
                this.viewport().widget('window').loadPage('new_project_library_citation_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var citation = new Library.Citation({context: this.context()});
                  citation.deleteSelected({collectionString: "Citation(s)"});
                });
                break;
              case 'Bulk Upload':
                window.location = me.context().routes().pathFor('bulk_upload_project_library_citations_path');
                break;
              case 'Citations Search':
                window.location = me.context().routes().pathFor('search_project_library_citations_path');
                break;
            }
          }
        }).call(this, event)
      }
    }
  })
});
//      onClick: function(event) {
//        var me = this;
//        Event.delegate({
//          '#create':function(event){
//            this.viewport().widget('window').loadPage('new_project_library_citation_path');
//               //show_div_new_citation();
//          },
//          '#bulk_upload':function(event){
////                new Ajax.Request("/projects/" + params['project_id'] + "/citations/bulk_upload", {
////                  method: 'get'
////                });
//
//                window.location = me.context().routes().pathFor('bulk_upload_project_library_citations_path');
//                //"http://"+window.location.host+params['path_prefix']+"/projects/" + params['project_id'] + "/library/citations/bulk_upload"
//          },
//          '#citations_search':function(event){
////                new Ajax.Request("/projects/" + params['project_id'] + "/citations/search", {
////                  method: 'get'
////                });
////
//                window.location = me.context().routes().pathFor('search_project_library_citations_path');
//                //"http://"+window.location.host+params['path_prefix']+"/projects/" + params['project_id'] + "/citations/search"
//          },
//          '#delete':function(event){
////              $('del_sel_cit').observe('click', function(event){
//                var hasConfirmed = confirm('Are you sure you would like to delete the selected citations?');
//                if (hasConfirmed) {
//                      form = $('list_items_form');
//                      form.writeAttribute('action', this.route('delete_selected_project_library_citations_path'))
//                      form.writeAttribute('method', 'post')
//                      document.getElementById('list_items_form').submit()
//                  }
////              }
//             }
//        }).bind(this)(event);
//      }
//    }
//  })
//})
