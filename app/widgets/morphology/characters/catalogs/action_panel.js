//= require <templates/tooltip>
//= require <widget>
//= require <widgets/taxa/action_panel_tool_tip>

Module('Morphology.Characters.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has:{
        collection_view: { is: 'ro', init: function () { return this.parent() } },
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
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' },
            { label: 'Add to Character Group', img: { src: "/images/small_arrow.png" }, imode: 'edit' },
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
                this.viewport().widget('window').loadPage('new_project_morphology_character_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var character = new Morphology.Character({context: this.context()});
                  character.deleteSelected({ collectionString: "Character(s)" });
                });
                break;
              case 'Add to Character Group':
                this.viewport().widget('window').loadPage('add_to_group_project_morphology_characters_path', {
                  conditions: this.catalog().selected().toString()
                });
                break;
              case 'Export':
                var action_panel = this;
                new Ajax.Request("/projects/" + params['project_id'] + "/morphology/characters/display_column_names", {
                  method: 'get',
                  onSuccess: function(transport) {
                    action_panel.tooltip().move(event.pointer());
                    action_panel.tooltip().update(transport.responseText);
                    action_panel.tooltip().show();
                  }
                });
                break;
            }
          }
        }).call(this, event)
      }
    }
  })
})
