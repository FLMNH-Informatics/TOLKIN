//= require <widget>
//= require <sync_collections/selected>
//= require <taxon>
//= require <templates/window>
//= require <roles/modified_scheduler>
//= require "tree_views/action_panel"
//= require <int_event_handler_set>
//= require <state>
//= require <roles/fires_events>

Module('Taxa', function () {
  JooseClass('TreeView', {
    isa:  Widget,
    does: Roles.ModifiedScheduler,
    has: {
      rootTaxa:        { is: 'ro', required: true, nullable: false },
      selectedName:    { init: null },
      clickTimeoutIds: { init: function () { return [] }},
      context:         { is: 'ro', required: true, nullable: false },
      collection:      { is: 'ro', init: function () { return(
        Taxon
          .collection({ context: this.context() })
          .where(false)
      )}},
      widgets:         { is: 'ro', init: function () { return $WSet({
        actionPanel: new Widgets.Taxa.TreeViews.ActionPanel({ parent: this })
      }, this)}},
      selected:        { is: 'ro',   init: function () { return new SyncCollections.Selected({ collection: Taxon.collection({ context: this.context() }) }) }},
      handlers: { is: 'ro', lazy: true, init: function () {
        return $Handlers([
        //this._cascadeStatesRenderedUnrendered(),
          this.selected().on({
            'select,deselect': function (event) {
              $(this.id()).down('.selected_count').update(event.memo().size()+' selected');
            },
            'selectAll': function (event) {
              $(this.id()).down('.selected_count').update(event.memo().size()+' selected');
              $$("input[type='checkbox']").each(function(item){ item.checked = true;  });
            },
            'deselectAll': function (event) {
              $(this.id()).down('.selected_count').update(event.memo().size()+' selected');
              $$("input[type='checkbox']").each(function(item){ item.checked = false;  });
            }
          }, this)
//        this.collection().on('collection:reloading', this.handleEvent.bind(this)),
//        this.collection().on('collection:loaded', this.handleEvent.bind(this)),
//        this.collection().on('collection:reloaded', this.handleEvent.bind(this))
        ], this)
      }}
    },
    after: {
      initialize: function () {
        this.handlers();
        this.collection().on('state:loaded', function () { if (this.render()) { this.refresh() }}, this)
       $(this.id()).select("input[type='checkbox']").each(function(checkbox){
          checkbox.setValue(0)//;
        })
        this.after('initialize');
      }
    },
    methods: {
      handleEvent: function (event) {
        switch(event.type()) {
          case 'record:updated':
            this.updateRow(event.memo().record);
        }
      },

      updateRow: function (record) {
        var node = $(this.id()).down('#taxon_'+record.id()+'_node');
        if(node) {
          node.down('span').update(record.attributes().name);
          var nodeName = node.down('.tree_view_node_name');
          if(record.attributes().namestatus_id == 1) { // namestatus = accepted_name, FIXME: flimsy - make this more robust dont rely on id val being 1
            if(!nodeName.hasClassName('accepted_name')) {
              nodeName.addClassName('accepted_name');
            }
          } else {
            if(nodeName.hasClassName('accepted_name')) {
              nodeName.removeClassName('accepted_name');
            }
          }
        }
      },

      render: function () {
        $(this.id()).replace(this.renderToString());
      },

      renderToString: function () {
        var nodes= this.rootTaxa().inject('', function(acc, taxon) {
          acc += this.context().templates().get('taxa/_node').evaluate({
            node : taxon,
            'expander_for(node)': (taxon.has_children) ? "+" : "",
            'raw node_name_element(node)': this._nodeNameElement(taxon)
          });
          return acc;
        }, this);
        return(
          "<div id='"+this.id()+"' class='tree_view widget'>"+
            this.widgets().get('actionPanel').renderToString()+
            "<table>"+
              nodes+
            "</table>"+
          "</div>"
        );
      },

      onDblClick: function(event) {
      //    if(this._clickTimeoutIds.size() > 0) {
      //            this._clickTimeoutIds.each(function(id) {
      //              window.clearTimeout(id);
      //            })
      //            this._clickTimeoutIds = [ ];
      //          }
      //          this._handleNodeNameDblClick(event);
      },

      onChange: function (event) {
        Event.delegate({
          "input[type='checkbox']": function (event) {
            var taxonId = event.element().getAttribute('value');
            //var taxonName = event.element().up('.tree_view_node').down('.tree_view_node_name').down('span').innerHTML;
            if($F(event.element())) {
              this.selected().selectId(taxonId);
            } else {
              this.selected().deselectId(taxonId);
            }
            
            
          }
        }).bind(this)(event);
      },

     _onNodeNameClick: function (event) {
        if(event.type == 'dblclick') {
          this.onDblClick(event);
        } else if (event.type == 'click' && event.shiftKey == true) {
          this.onShiftClick(event);
        //} else if(isAPressed && event.type == 'click' && isAPressed == true){
          // isAPressed = false;
          //this.parent().globalCart().add('Taxon', event.element().up('.tree_view_node').id.match(/taxon_(\d+)_node/)[1], event.element().innerHTML)
        } else if(event.type == 'click' && this.widgets().get('actionPanel').move_btn_click == true) {
          this.widgets().get('actionPanel').move_btn_click = false;
          this.widgets().get('actionPanel')._moveCurrentSelection(event.element().up('.tree_view_node').id.match(/taxon_(\d+)_node/)[1]);
        }  else {
          this.setSelectedElement(event.element());

          var id = this._taxonIdForEvent(event);
          this.context().currentSelection().set({ type: 'Taxon', id: id, label: event.element().innerHTML});
          params['id'] = id;
          var window = this.viewport().widgets().get('window');
          //var queue = new Queue();
          //queue.join(
          window.on('page:loaded', function (event) {
            event.from().show();
          });
          window.loadPage('project_taxon_path', { id: id });
        }
      },

      onClick: function(event) {
        var me = this;
        Event.delegate({
          '.tree_view_expander': function(event) {
            var taxonId = this._taxonIdForEvent(event);
            var taxon = new Taxon({ id: taxonId, context: this.context() });

            if(event.element().innerHTML == '+') {
              $('taxon_' + taxon.id() + '_node').down('.tree_view_expander').update('‒');
              $('taxon_' + taxon.id() + '_node').down('.tree_view_node_name').insert({
                bottom: "<span class='throbber'>&nbsp;&nbsp;<img src='/images/ajax-loader.gif' width='10px' height='10px' /></span>"
              })
              taxon.loadChildren({
                callback: function () { me._showTaxonChildren(taxon) }
              });
            } else if(event.element().innerHTML == '‒') {
              this._hideTaxonChildren(taxon);
            }
          },
          '.tree_view_node_name span': function(event) {
            if(this.context().currentSelection()) {
              this._onNodeNameClick(event);
            } else {
              this.context().on(
                'current_selection:loaded',
                function () { me._onNodeNameClick(event) },
                { once: true }
              )
            }
          }
        }).bind(this)(event);
      },

      onShiftClick: function(event) {
//        Notifier.error('not working yet: FIXME');
//        Cart.add('Taxon', event.element().up('tr').id.match(/taxon_(\d+)_node/)[1]);
      },

      setSelectedElement: function(element) {
        if(this._selectedName) {
          this._selectedName.removeClassName('selected');
        }
        this._selectedName = element;
        this._selectedName.addClassName('selected');
      },

      _hideTaxonChildren: function(taxon) {
        $('taxon_' + taxon.id() + '_node').down('.tree_view_expander').update('+');
        $('taxon_' + taxon.id() + '_node').down('.tree_view_node_children').update('');
        var throbber = $('taxon_' + taxon.id() + '_node').down('.throbber');
        if(throbber) { throbber.remove() }
      },

      _setSelectedName: function() {
//        if(this.parent().globalCart().loaded() == false) {
//          setTimeout(this._setSelectedName.bind(this), 100);
//        }
        if(!this._selectedName && this.context().currentSelection().get() && this.context().currentSelection().get().type == 'Taxon') {
          if($('taxon_' + this.context().currentSelection().get().id + "_node")) {
            this._selectedName = $('taxon_' + this.context().currentSelection().get().id + "_node").down('.selected');
          }
        }

      },

      _showTaxonChildren: function(taxon) {
        var out = ""
        var treeView = this
        taxon.children.each(function(childTaxon) {
          out += treeView.parent().templates().get('taxa/_node').evaluate({
            node : childTaxon,
            'expander_for(node)': (childTaxon.has_children) ? "+" : "",
            'raw node_name_element(node)': treeView._nodeNameElement(childTaxon)
          });
        });
        var expander = $('taxon_' + taxon.id() + '_node').down('.tree_view_expander');
        if(expander.innerHTML == '\u2012') { $('taxon_' + taxon.id() + '_node').down('.tree_view_node_children').update(out) }
        
        var throbber = $('taxon_' + taxon.id() + '_node').down('.throbber');
        if(throbber) { throbber.remove() }

        this._setSelectedName();

      },

      _nodeNameElement: function(taxon) {
        var divClasses = [ 'tree_view_node_name' ];
        var taxonNamestatus = taxon.namestatus ? taxon.namestatus.namestatus.status : null;
        if(taxonNamestatus == 'accepted_name') {
          divClasses.push(taxonNamestatus);
        }
        var curSelection = this.context().currentSelection().get()
        var spanClass = (curSelection && curSelection.type == 'Taxon' && curSelection.id == taxon.id) ? " class='selected'" : ""
        return "<div class='#{divClasses}'><span#{spanClass}>#{taxon.name}</span></div>".interpolate({
          divClasses: divClasses.join(' '),
          spanClass: spanClass,
          taxon: taxon
        })
      },

      _taxonIdForEvent: function(event) {
        return event.element().up('.tree_view_node').id.match(/taxon_(\d+)_node/)[1];
      }
    }
  })
});

