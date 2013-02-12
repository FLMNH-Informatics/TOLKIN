//= require <widgets/templates/tooltip>
//= require <widget>
//= require <widgets/taxa/action_panel_tool_tip>
//= require <taxa/new_window>
//= require <templates/action_panel>


Module('Taxa.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has:{
      catalog: {
        is: 'ro', init: function () { return this.parent(); }
      },
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
          { label: 'Delete', img: { src: "/images/small_cross.png" },  imode: 'edit' },
          { label: 'Export', img: { src: "/images/small_report.png" }, imode: [ 'browse', 'edit' ] },
          { label: 'Set Permissions', imode: 'edit' }
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
                this.viewport().widget('window').loadPage('new_project_taxon_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var tax = new Taxon({context: me.context()});
                  tax.deleteSelected({ collectionString: "Taxa" });
                })
                break;
              case 'Export':
                var action_panel = this;
                new Ajax.Request("/projects/" + params['project_id'] + "/taxa/display_taxa_column_names", {
                  method: 'get',
                  onSuccess: function(transport) {
                    action_panel.tooltip().move(event.pointer());
                    action_panel.tooltip().update(transport.responseText);
                    action_panel.tooltip().show();
                  }
                })
                break;

              case 'Set Permissions':
                switch (this.catalog().selected().toString()){
                  case 'true':
                     alert('Cannot set permissions on entire catalog!');
                     break;
                  case 'false':
                     alert('Must select catalog item(s)!');
                     break;
                  default:
                    this.viewport().widget('window').loadPage('set_permissions_view_project_taxa_path', {
                      conditions: this.catalog().selected().toString()
                    })
                    break;
                }
                break;
            }
          }
        }).bind(this)(event);
      }
    }
  })
});
