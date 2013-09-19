//= require <templates/tooltip>
//= require <widget>
//= require <molecular/dna_samples/action_panel_tool_tip>
//= require <templates/action_panel>
//= require <templates/action_panel_upload>

Module('Molecular.DnaSamples.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    does: ActionPanelUpload,
    has:{
      catalog: { is: 'ro', init: function () { return this.parent() } },
      tooltip: { is: 'ro', init: function(){
          var toltip = new Widgets.Molecular.DnaSamples.ActionPanelToolTip({
            parent: this.viewport() ,
            catalog_obj: this.parent()
          });
          this.viewport().widgets().add(toltip );
          return toltip;
      }},
      buttons: {
        is: 'ro',
        init: [
          {label: 'Create', img: {src: "/images/small_addnew.gif"}, imode: 'edit'},
          {label: 'Delete', img: {src: "/images/small_cross.png"}, imode: 'edit'}
//          {label: 'Create a Report', img: {src: "/images/small_report.png"}, imode: [ 'browse', 'edit' ]}
        ]
      }
    },
    methods: {
      onClick: function(event) {
        var me = this;
        Event.delegate({
          'input[type="button"]': function(event) {
            switch (event.element().readAttribute('value')) {
              case 'Create':
                this.viewport().widget('window').loadPage('new_project_molecular_dna_sample_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var dna = new Molecular.DnaSample({ context: this.context() });
                  dna.deleteSelected({collectionString: "DNA sample(s)"});
                })
                break;
              case 'Create a Report':
                var action_panel = this;
                new Ajax.Request("/projects/" + params['project_id'] + "/molecular/dna_samples/display_column_names", {
                  method: 'get',
                  onSuccess: function(transport) {
                    action_panel.tooltip().move(event.pointer());
                    action_panel.tooltip().update(transport.responseText);
                    action_panel.tooltip().show();
                  //action_panel.injectSearchConditions();
                  },
                  onFailure: function() {
                    action_panel.notifier().error('Problem exporting.');
                  }
                })
                break;
            }
          }
        }).call(this, event)
      },

      hideTooltip: function() {
        if(this.tooltip) {
          this.tooltip.hide();
        }
      },

      showTooltip: function(tooltipContents, pointer) {
        this.tooltip = new Widgets.Templates.Tooltip({ parent: this, contents: tooltipContents});
        this.tooltip.move(pointer)
        this.tooltip.show();
      }

    }
  })
});
