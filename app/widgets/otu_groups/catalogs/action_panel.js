//= require <templates/tooltip>
//= require <widget>
//= require <widgets/taxa/action_panel_tool_tip>

Module('OtuGroups.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has:{
      catalog: { is :'ro', init: function() {return this.parent(); } },
      collection_view: { is: 'ro', init: function () { return this.parent() } },
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
          { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
          { label: 'Export', img: { src: "/images/small_report.png" }, imode: ['browse','edit'] }
          //{ label: 'Add Otu to Group', img: { src: "/images/small_addnew.gif" }, imode: 'edit' }
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
                me.viewport().widget('window').loadPage('new_project_otu_group_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var otuGroup = new OtuGroup({context: me.context()});
                  otuGroup.deleteSelected({ collectionString: "Otu Group(s)" });
                });
                break;
              case 'Add Otu to Group':
               
                me.viewport().widget('window').loadPage('add_otu_to_group_project_otu_groups_path');
                break;
              case 'Export':
                var action_panel = this;
                new Ajax.Request("/projects/" + params['project_id'] + "/otu_groups/display_column_names", {
                  method: 'get',
                  onSuccess: function(transport) {
                    action_panel.tooltip().move(event.pointer());
                    action_panel.tooltip().update(transport.responseText);
                    action_panel.tooltip().show();
                  }
                })
                break;
            }
          }
        }).call(this, event)
      }
    }
  })
});