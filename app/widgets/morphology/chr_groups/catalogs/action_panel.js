//= require <widgets/templates/tooltip>
//= require <widget>


Module('Morphology.ChrGroups.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has: {
      catalog: { is: 'ro', init: function () { return this.parent() } },
      tooltip: {
        is: 'ro',
        init: function(){
          var toltip = new Taxa.ActionPanelToolTip({
            parent: this.viewport(),
            catalog_obj: this.parent()
          });
          this.viewport().widgets().add(toltip );
          return toltip;
        }
      },
      buttons: {
        is: 'ro',
        init: [
          { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
          { label: 'Delete', img: { src: "/images/small_cross.png"  }, imode: 'edit' },
          { label: 'Export', img: { src: "/images/small_report.png" }, imode: ['browse','edit'] }
        ]
      }
    },
    methods: {
      onClick: function(event) {
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Create':
                new Ajax.Request(Route.forPathname('new_project_morphology_chr_group_path').buildPath(this.params()), {
                  method: 'get'
                })
                break
              case 'Delete':
                this.requireSelection(function(){
                  var chrGrp = new Morphology.ChrGroup({context: this.context()});
                  chrGrp.deleteSelected({ collectionString: "character group(s)" });
                });
                break;
              case 'Export':
                var action_panel = this;
                new Ajax.Request("/projects/" + params['project_id'] + "/morphology/chr_groups/display_column_names", {
                  method: 'get',
                  onSuccess: function(transport) {
                    action_panel.tooltip().move(event.pointer())
                    action_panel.tooltip().update(transport.responseText);
                    action_panel.tooltip().show();
                  }
                })
                break
            }
          }
        }).bind(this)(event);
      }
    }
  })
});
//      onClick: function(event) {
//        Event.delegate({
//          '#create':function(event){
//                new Ajax.Request("/projects/" + params['project_id'] + "/chr_groups/new", {
//                  method: 'get'
//                });
//          },
//          '#delete':function(event){
//                var hasConfirmed = confirm('Are you sure you would like to delete the selected character groups?');
//                if(hasConfirmed) {
//                  $('list_items_form').writeAttribute('action',"/projects/" + params['project_id'] + "/chr_groups/delete_selected");
//              $('list_items_form').writeAttribute('method','post');
//              $('list_items_form').submit();
//                }
//          }
//        }).bind(this)(event);
//      }
//    }
//  })
//});
