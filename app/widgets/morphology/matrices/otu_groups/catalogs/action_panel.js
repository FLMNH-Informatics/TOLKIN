//= require <widgets/templates/tooltip>
////= require <collection>
//= require <widget>
//= require <widgets/collections/action_panel_tool_tip>

Module('Widgets.Morphology.Matrices.OtuGroups.Catalogs', function () {
  JooseClass('ActionPanel', {
    does: [ Roles.FiresEvents],
    isa: Widget,
    has:{
        collection_view: { is: 'ro', init: function () { return this.parent() } },
        context:{ is:'rw', init :''}
        
    },
    after: {
      initialize: function () {
//        this.collection_view().after({ initialize: function () {
//          this.collection_view().selected().channel('me:widgets').addListener(this);
//        }}, this)
      }
    },
    methods: {
      renderToString: function () {
        return this.context().templates().get('morphology/matrices/otu_groups/catalogs/_action_panel').evaluate({
          id: this.id(),
          count_num: this.parent().selected().size()+' selected'
        })
      },

      onClick: function(event) {
        Event.delegate({
          '#delete':function(event){

//               if(this.collection_view().selected().toString().length > 0){
//                  var input = document.createElement("input");
//                  input.name = 'conditions';
//                  input.type = "hidden";
//                  input.value = this.collection_view().selected().toString();
//                  $(this.id()).down('form').appendChild(input);
//               }
               
                event.stop();
            //    $(this.id()).down('form').submit();
            var me = this;
             var record =  new Morphology.Matrices.MorphologyMatricesOtuGroups({ context: this.context() })
            new Ajax.Request("/projects/" + params['project_id'] + "/matrices/"+params['id']+"/morphology_matrices_otu_groups/destroy_all", {
                  method: 'delete',
                  parameters:{conditions: me.collection_view().selected().toString() },
                  onSuccess: function(transport) {
                     record.fire('records:destroy', { memo: me })
                  },
                  onFailure: function() {

                  }
                })

          }
        }).bind(this)(event);
      }
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
    }
  })
});