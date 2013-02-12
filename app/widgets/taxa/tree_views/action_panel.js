//= require <templates/tooltip>
//= require <taxon>
//= require <widget>
//= require <taxa/new_page>
//= require <taxa/action_panel_tool_tip>
//= require <taxa/action_panel_tool_tip_for_otu>


Module('Widgets.Taxa.TreeViews', function () {
  JooseClass('ActionPanel', {
    isa: Widget,
    has: {
        treeView: { is: 'ro', init: function () { return this.parent() } },
        move_btn_click: { is: 'rw', init: false, nullable: false},
        tooltip:         { is: 'ro', init: function(){
              var toltip = new Taxa.ActionPanelToolTip({ parent: this.viewport(),
            catalog_obj: this.parent() });
              this.viewport().widgets().add(toltip );
              return toltip;
            } },
        otu_tooltip:         { is: 'ro', init: function(){
            var toltip = new Taxa.ActionPanelToolTipForOtu({ parent: this.viewport(),
          catalog_obj: this.parent() });
            this.viewport().widgets().add(toltip );
            return toltip;
          } }
        
    },
    after: {
      initialize: function () {
//        this.treeView().after({ initialize: function () {
//          this.treeView().selected().channel('me:widgets').addListener(this);
//        }}, this)
      }
    },
    methods: {
      renderToString: function () {
        return this.context().templates().get('taxa/tree_views/_action_panel').evaluate({
          id: this.id()
        })
      },
      onClick: function(event) {
        Event.delegate({
          '#delete_taxon_button': function(event) {
//            if(this.parent().top().currentSelection().get()){
//              var item_type ={
//                type: this.parent().top().currentSelection().get().type
//              };
//              Taxon.destroy(item_type, this.context());
//            }else{
//              this.notifier().warning('Please select taxon in to Current Selection and then click delete');
//            }
             var match = this.treeView().selected().toString().match(/^([\d,]+)\[taxon_id\]/)
            if (match) {
              params['treeViewSelected'] = match[1]
              if(params['treeViewSelected']) {
                var item_type ={
                taxa_ids_to_delete: params['treeViewSelected']
                }
                Taxon.destroy(item_type, this.context(), this.parent());
              } else {
                this.notifier().working('Please check taxa to delete.');
              }
            } else {
              this.notifier().warning('No taxa selected to move.')

            }
            
          },
          '#move_taxon_button': function(event) {
            var match = this.treeView().selected().toString().match(/^([\d,]+)\[taxon_id\]/)
            if (match) {
              params['treeViewSelected'] = match[1]
              if(params['treeViewSelected']) {
                this.move_btn_click = true;
                this.notifier().working('Please click name of new parent taxon.');
              } else {
                this.notifier().working('Please check taxa to move and press move again.');
              }
            } else {
              this.notifier().warning('No taxa selected to move.')

            }

//            if(this.parent().top().currentSelection().get()){
//              this.move_btn_click = true;
//              this.notifier().working('Please click a Taxon to move Current Selection');
//            }else{
//               this.notifier().warning('Please select taxon in to Current Selection and then click move');
//            }
          },
          '#add_to_otu':function(event){

                 var render_html =    '<form id="adding_to_otu">'+ 
                          '<input type="text" name="otu_name" id="otu_name">'+
                          '<div id="add_to_otu_button">'+
                            '<input type="submit" value="add to otu">'+
                          '</div>'+
                        '</form>'

             this.otu_tooltip().update(render_html);
                    this.otu_tooltip().move(event.pointer())
                    this.otu_tooltip().show();
//            $('add_to_otu_window').style.display="block";
          },
          '#add_to_otu_button':function(event){
        
          },
          '#create_taxon_at_root':function(event){
           // var window = new Taxa.NewPage({parent: this.parent()});

            var window = this.viewport().widgets().get('window');
            //    var queue = new Queue();
            //queue.join(
            window.loadPage('new_project_taxon_path')
            //)
            //queue.add(function () {
            //window.on('state:pageRendered', window.show.bind(window), { once: true })
            //window.show()
            //});
            //window.loadContents({onSuccess: window.render});
                    //$('taxon_root_window').style.display="block";
          },
          '#export_to_csv':function(event){
            var action_panel = this;
            new Ajax.Request("/projects/" + params['project_id'] + "/taxa/display_taxa_column_names", {
                  method: 'get',
                  onSuccess: function(transport) {
//                    var tooltip = action_panel.widgets().get('tooltip')
                    action_panel.tooltip().update(transport.responseText);
                    action_panel.tooltip().move(event.pointer())
                    action_panel.tooltip().show();
                  },
                  onFailure: function() {
                    
                  }
                })
            
            
          }
        }).bind(this)(event);
      },
      hideTooltip: function() {
        if(this.tooltip) {
          this.tooltip.hide();
        }
      },

      showTooltip: function(tooltipContents, pointer) {
        this.tooltip = new Templates.Tooltip({ parent: this, contents: tooltipContents});
        this.tooltip.move(pointer)
        this.tooltip.show();
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
          //type: this.parent().top().currentSelection()._value.type,
          parent_taxon_id: id,
          taxa_ids_to_move: params['treeViewSelected']
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
              action_panel.parent().selected().deselectId(moved_item[i]);
            }
            $('taxon_' + new_parent + '_node').down('.tree_view_expander').update('+');
            $('taxon_' + new_parent + '_node').down('.tree_view_node_children').update('');


           action_panel.notifier().success('Current Selection  successfully moved');
          },
          onFailure: function() {
            action_panel.notifier().success('problem moving current selection');
          }
        })
      }
    }
  })
})