//= require <widgets/templates/tooltip>
//= require <widget>
//= require <morphology/matrix>

Module('Morphology.Matrices.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has:{
       catalog: { is: 'ro', init: function () { return this.parent() } },
       collection_view: { is: 'ro', init: function () { return this.parent() } },
       buttons: {
         is: 'ro',
         init: [
           { label: 'Create',             img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
           { label: 'Delete',             img: { src: "/images/small_cross.png" },  imode: 'edit' },
           { label: 'Import Matrix',      img: { src: "/images/small_import.png" }, imode: 'edit' },
           { label: 'Modify Matrix',      img: { src: "/images/small_edit.png" },   imode: 'edit' },
           { label: 'Export Nexus file',  img: { src: "/images/sm_upload.png" },     imode: 'edit' }
//todo: implement these features:
//           { label: 'Merge Matrix', img: { src: "/images/small_merge.png" }, imode: 'edit' },
//           { label: 'Designate Submatrix', img: { src: "/images/small_submatrix.png" }, imode: 'edit' }
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
                this.viewport().widget('window').loadPage('new_project_morphology_matrix_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var matrix = new Morphology.Matrix({context: me.context()});
                  matrix.deleteSelected({ collectionString: "Matrices" });
                });
                break;
              case 'Import Matrix':
                //var window = this.viewport().widgets().get('window');
                document.location.assign("http://" + document.location.host+(params['path_prefix']||'') + me.context().routes().pathFor('new_project_nexus_dataset_path'));
//                new Ajax.Request("/projects/" + params['project_id'] + "/nexus_datasets/new", {
//                  method: 'get',
//                  onSuccess: function (variable) {
//                    //responseToText()
//                  }
//                });
                break;
              case 'Modify Matrix':
                var catalog_hash = $('list_items_form').serialize(true);
                if ( catalog_hash['data[]'] != null){
                  document.location.assign("http://" + document.location.host+(params['path_prefix']||'')+'/projects/'+ params["project_id"] +'/morphology/matrices/'+[catalog_hash['data[]'] ].flatten()[0]+'/modify_matrix');
                }
                break;
              case 'Merge Matrix':
                var window = this.viewport().widgets().get('window');
                window.loadPage('show_merge_matrices_project_morphology_matrices_path');
//                new Ajax.Request("/projects/" + params['project_id'] + "/morphology/matrices/show_merge_window", {
//                  method: 'get'
//                });
                break;
              case 'Designate Submatrix':
                var window = this.viewport().widgets().get('window');
                window.loadPage('show_designate_submatrix_project_morphology_matrices_path');
//                new Ajax.Request("/projects/" + params['project_id'] + "/morphology/matrices/show_designate_submatrix_window", {
//                  method: 'get'
//                });
                break;
              case 'Export Nexus file':
                if (me.parent().selected() && me.parent().selected().size() == 1){
                  me.notifier().success('Exporting nexus file...');
                  document.location.assign("http://" + document.location.host + '/projects/' + params['project_id'] + '/morphology/matrices/' + me.parent().selected()._ids.toString() + '/do_export');
                }else{me.notifier().warning('You must selected only one matrix to export.');}
                break;
            }
          }
//          '#create':function(event){
//                new Ajax.Request("/projects/" + params['project_id'] + "/matrices/new", {
//                  method: 'get'
//                });
//          },
//          '#modify_matrix':function(event){
//
//            var catalog_hash = $('list_items_form').serialize(true);
//            if ( catalog_hash['data[]'] != null){
//              window.location.assign("http://"+window.location.host+(params['path_prefix']||'')+'/projects/'+ params["project_id"] +'/morphology/matrices/'+[catalog_hash['data[]'] ].flatten()[0]+'/modify_matrix');
//            }
////            var matrix_id = $('list_items_form').down('.selected_row').getAttribute('data-id');
//          },
//          '#import_matrix': function(){
//              new Ajax.Request("/projects/" + params['project_id'] + "/nexus_datasets/new", {
//                  method: 'get'
//                });
//          },
//          '#merge_matrices': function(){
//              new Ajax.Request("/projects/" + params['project_id'] + "/matrices/show_merge_window", {
//                  method: 'get'
//                });
//          },
//          '#designate_submatrix': function(){
//              new Ajax.Request("/projects/" + params['project_id'] + "/matrices/show_designate_submatrix_window", {
//                  method: 'get'
//                });
//          },
//          '#delete':function(event){
//              var hasConfirmed = confirm('Are you sure you would like to delete these matrices ?');
//              if(hasConfirmed) {
//                form = $('list_items_form');
//                form.writeAttribute('action', '/projects/'+ params["project_id"] +'/morphology/matrices/delete_selected');
//                form.writeAttribute('method', 'post');
//                form.request({
//                  onSuccess: function () {
//                    me.notifier().success('Matrices deleted successfully.');
//                    var record = new Morphology.Matrix({context: me.context()});
//                    record.fire('destroy', { memo: { record: record }});
//                  },
//                  onFailure: function () {
//                    me.notifier().error('Matrices could not be deleted.');
//                  }
//                });
//              }
//            }
        }).call(this, event);
      }
    }
  })
});
