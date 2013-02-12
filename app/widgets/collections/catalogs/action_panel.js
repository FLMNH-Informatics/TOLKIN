//= require <templates/tooltip>
//= require <widget>
//= require <collections/action_panel_tool_tip>
//= require <collections_helper>
//= require <templates/action_panel>

Module('Collections.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    does: CollectionsHelper,
    has: {
      catalog: { is: 'ro', init: function(){ return this.parent(); } },
      collection_view: { is: 'ro', init: function () { return this.parent() } },
      buttons: {
        is: 'ro',
        init: [
          { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
          { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
          { label: 'Export', img: { src: "/images/small_report.png" }, imode: [ 'browse', 'edit' ] }
        ]
      },
      tooltip: { is: 'ro', init: function () {
          var toltip = new Collections.ActionPanelToolTip({
            parent: this.viewport() ,
            catalog_obj: this.parent()
          });
          this.viewport().widgets().add(toltip)
          return toltip;
        }
      }
    },
    methods: {
      onClick: function(event) {
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Create':
                var window = this.viewport().widgets().get('window');
                window.loadPage('new_project_collection_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                    var collection = new Collection({context: this.context()});
                    collection.deleteSelected({collectionString: "Collection(s)"});
                });
                break;
              case 'Export':
                var me = this;
                new Ajax.Request("/projects/" + params['project_id'] + "/collections/display_collection_column_names", {
                  method: 'get',
                  onSuccess: function(transport) {
                    me.tooltip().move(event.pointer())
                    me.tooltip().update(transport.responseText);
                    me.tooltip().show();
                  //action_panel.injectSearchConditions();
                  },
                  onFailure: function() {
                    me.context().notifier().error('Error exporting to CSV');
                  }
                });
                break;
            }
          }
        }).call(this, event)
      }
    //    }
    //  })
    //});
    }
  })
});
  //      onClick: function(event) {
  //        Event.delegate({
  //          '.button.active[value="Export"]': function (event) {
  //            var me = this;
  //            new Ajax.Request("/projects/" + params['project_id'] + "/collections/display_collection_column_names", {
  //              method: 'get',
  //              onSuccess: function(transport) {
  //                me.tooltip().move(event.pointer())
  //                me.tooltip().update(transport.responseText);
  //                me.tooltip().show();
  //              //action_panel.injectSearchConditions();
  //              },
  //              onFailure: function() {
  //                me.context().notifier().error('Error exporting to CSV');
  //              }
  //            });
  //          },
  //          '.button.active[value="Create"]':function(event){
  //              //var queue = new Queue();
  //              var window = this.viewport().widgets().get('window');
  //              //queue.join(
  //              window.loadPage('new_project_collection_path');
  //              //queue.add(window.show.bind(window));
  //              //queue.flush();
  //            //window.location.assign("http://"+window.location.host+(params['path_prefix']||'')+'/projects/'+params['project_id']+'/collections/new');
  //          },
  //          '.button.active[value="Delete"]':function(event){
  //            var me = this;
  //            var hasConfirmed = confirm('Are you sure you would like to delete the selected collections?')
  //            if(hasConfirmed) {
  //              var formId = 'list_items_form'
  //              var form = $(formId)
  //              form.writeAttribute('action', this.route('delete_selected_project_collections_path'))
  //              //'/projects/'+params['project_id']+'/collections/delete_selected');
  //              form.writeAttribute('method', 'post')
  //              form.request({
  //                onSuccess: function () {
  //                  var triggerDelete = new Collection({ context: me.context() })
  //                  triggerDelete.fire('destroy')
  //                  me.context().notifier().success("Collections successfully deleted.")
  //                }
  //              });
  //            //                  return false;
  //            }
  //          }
  //        }).bind(this)(event);
  //      }
  //      ,
  //      hideTooltip: function() {
  //        if(this.tooltip) {
  //          this.tooltip.hide();
  //        }
  //      },
  //
  //      showTooltip: function(tooltipContents, pointer) {
  //        this.tooltip = new Widgets.Templates.Tooltip({ parent: this, contents: tooltipContents});
  //        this.tooltip.move(pointer)
  //        this.tooltip.show();
  //      }
