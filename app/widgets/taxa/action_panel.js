//= require <taxon>
//= require <widget>
//= require "new_window"


Module('Widgets.Taxa', function () {
  JooseClass('ActionPanel', {
    isa: Widget,
    has:{
        move_btn_click: { is: 'rw', isa: Joose.Type.Bool, init: false, nullable: false }
    },
    methods: {
      onClick: function(event) {
        Event.delegate({
          '#delete_taxon_button': function(event) {
            if(this.parent().top().currentSelection().get()){
              var item_type ={
                type: this.parent().top().currentSelection().get().type
              };
              Taxon.destroy(item_type, this.context());
            }else{
              this.notifier().warning('Please select taxon in to Current Selection and then click delete');
            }
            
            
          },
          '#move_taxon_button': function(event) {
            if(this.parent().top().currentSelection().get()){
              this.move_btn_click = true;
              this.notifier().working('Please click a Taxon to move Current Selection');
            }else{
               this.notifier().warning('Please select taxon in to Current Selection and then click move');
            }
          },
          '#add_to_otu':function(event){
            $('add_to_otu_window').style.display="block";
          },
          '#add_to_otu_button':function(event){
            if(this.parent().top().currentSelection().get()){
                var otu_name = {
                  otu_name: $('otu_name').value,
                  type: this.parent().top().currentSelection().get().type

                }
                var action_panel = this
                action_panel.notifier().working('Adding current selection to Otus ...');
                new Ajax.Request("/projects/" + params['project_id'] + "/taxa/add_to_otu", {
                  method: 'post',
                  parameters:otu_name ,
                  onSuccess: function(transport) {
                    $('add_to_otu_window').style.display="none";
                   action_panel.notifier().success('Current Selection added to Otus');
                  },
                  onFailure: function() {
                    action_panel.notifier().success('problem adding otus');
                  }
                });
            }else{
              this.notifier().warning('Please select taxon in to Current Selection and then click add to Otu');
            }
          },
          '#create_taxon_at_root':function(event){
            var window = new Widgets.Taxa.NewWindow({parent: this.viewport()});
            this.viewport().widgets().add(window);
            
            window.loadContents();
          //window.loadContents({onSuccess: window.render});
          //          $('taxon_root_window').style.display="block";
          }
        }).bind(this)(event);
      },

      //  _add_to_Otu: function(){
      //
      //  },

      _destroyCurrentSelection: function() {
        
      //    if (CurrentSelection.currentSelection().id){
      //
      //    }else
      //    new Taxon(CurrentSelection.currentSelection().id).destroy();
      },

      _moveCurrentSelection: function(id){          
        var item_klass ={
          type: this.parent().top().currentSelection()._value.type,
          parent_taxon_id: id
        };
        var action_panel = this
        new Ajax.Request("/projects/" + params['project_id'] + "/taxa/"+id+"/move_to", {
          method: 'put',
          parameters:item_klass ,
          onSuccess: function(transport) {
            var moved_item = transport.responseText.evalJSON();
            var new_parent =  item_klass.parent_taxon_id;
            for(i=0; i<moved_item.length ; i++){
              if($('taxon_' + moved_item[i] + '_node')){
                $('taxon_' + moved_item[i] + '_node').remove()
              }
            }
            $('taxon_' + new_parent + '_node').down('.tree_view_expander').update('+');
            $('taxon_' + new_parent + '_node').down('.tree_view_node_children').update('');

           action_panel.notifier().success('Current Selection  successfully moved');
          },
          onFailure: function() {
            action_panel.notifier().success('problem moving current selection');
          }
        });
      }
    }
  })
});
