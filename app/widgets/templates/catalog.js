//= require <widget>
//= require <cycle>
//= require <lowpro>
//= require "catalogs/filter_set"
//= require "null"
//= require <sync_collections/selected>
//= require <general/drag_tooltip>
//= require <int_event_handler_set>
//= require <state>
//= require <roles/stateful>
//= require <publifier>

Module('Templates', function() {
  JooseClass('Catalog', {
    isa: Widget,
    does: [Stateful,ShiftChecking],
    isAbstract: true,
    has: {
      emptyMsg:         { is: 'ro', init: 'No results found.' },
      hasFilterSet:     { is: 'ro', init: true},
      hasContentsForm:  { is: 'ro', init: true },
      collection:       { is: 'ro', required: true, nullable: false},
      cycle:            { is: 'ro', lazy: true, init: function() { return new TOLJS.Cycle(); }},
      canPublify:       { is: 'rw', lazy: true, init: function () {
        if (this._collection._data){return this._collection._data.can_publify;}else{ return false;}} },
      dataId:           { is: 'ro', init: 'id' }, // id that should be used for checkboxes / form submission (in the case of matrices especially
      loaded:           { is: 'ro', init: false},
      showFiller:       { is: 'ro', init: true},
      limit:            { is: 'rw', init: 20 },
      states: { is: 'ro', init: function () { return new State([
        [ 'notDisplayed', 'loadingDisplayed', 'loadedDisplayed' ] // FIXME: loadedDisplayed not getting set for all catalogs belonging to parent widgets loaded into page
      ], this) } },

      columns:          { is: 'ro', required: true, nullable: false},
      resizingColumn: { },
      resizeNodesArr: { init: function () { return []; } },
      minResizeWidth: { init: 19 },
      columnResizeXStart: { },
      draggables:         { init: function () {return [];}},
      dragHover:          { init: false },
      curr_order:         { init: 'ascending' },
      curr_column:        { },
      selected:           { is: 'ro', 
                            lazy: true, // lazy required, this.collection() does not exist yet
                            init: function () { return new SyncCollections.Selected({ collection: this.collection() }) }
                          },
      widgets:            { is: 'ro', init: function () {return $Reg({
            actionPanel: new Templates.Null({parent: this}),
            filterSet:
              this.hasFilterSet() ?
                new Templates.Catalogs.FilterSet({context: this.context(), parent: this, catalog: this})
                : new Templates.Null({parent: this})
      }, this);}}
    },
    after: {
      limit: function () {
        return (this._limit || this.collection().limit())
      },

      initialize: function() {
        this.handlers();
        this.state().set($(this.id()) ? 'loadedDisplayed' : 'notDisplayed');
        if(this.state().is('loadedDisplayed')) {
          //this.state().set($(this.id()).down('.spinner') ? 'loading' : 'idle');
          Droppables.add(this.id(), {
            hoverclass: 'draghover',
            onDrop: this.onDrop.bind(this)
          });
          this._initResizeNodesArr();
        }
        if(this._hasFilterSet == true){
          this.filters().getFilters();
        }
        if($(this.id())) {
          this.selected().deselectAll()
        }
        this.handlers().push(
          this.collection().on({
            'loading': function () {
              if ($(this.id())) { this.renderSpinner(); }
            },
            'loaded': function () {
              if ($(this.id())) { this.renderTable(); }
            },
            'recordsDestroyed': function () { this.selected().deselectAll(); },
            'recordCreated':    function () { this.selected().deselectAll(); }
          }, this)
        )
        this.handlers().push(
          this.selected().on({
            'select,deselect': function (event) {
              if($(this.id()).down('.selected_count')) {
                $(this.id()).down('.selected_count').update(event.memo().size()+' selected');
                if (event.memo().size() > 0){this.showSelectionTools();}else{this.hideSelectionTools()}
                this.updateFormConditions();
              }
            },
            'selectAll': function (event) {
              if($(this.id()).down('.selected_count')) {
                $(this.id()).down('.selected_count').update(event.memo().size()+' selected');
                this.showSelectionTools();
              }
              $(this.id()).select("input[type='checkbox']").each(function(checkbox){
                checkbox.setValue(1);
                this.selectDeselectRowFor(checkbox);
              }, this);
              this.updateFormConditions();
            },
            'deselectAll': function (event) {
              if($(this.id()).down('.selected_count')) {
                $(this.id()).down('.selected_count').update(event.memo().size()+' selected');
                this.hideSelectionTools();
              }
              $(this.id()).select("input[type='checkbox']").each(function(checkbox){
                checkbox.setValue(0);
                this.selectDeselectRowFor(checkbox);
              }, this);
              this.updateFormConditions();
            }
          }, this)
        )
        this.handlers().push(
          this.on('state:loadedDisplayed', function () {
            if($(this.id())) {
              if (this.selected().toString() == 'false'){
                this.selected().deselectAll();
              }else if (this.collection()._finderOptions.offset) {}
            }
          }, this)
        )
      }
    },
    before: {
      unload: function() {
        this.collection().unload()
        Event.stopObserving(this.id(), 'mouseover');
        Event.stopObserving(this.id(), 'mouseout');
        this._draggables.each(function(draggable) {
          draggable.destroy();
        });
      }
    },
    methods: {
      state: function () {
        return this.states();
      },
       
      page: function () {
        return (this.collection().offset() === 0 ? 1 : (this.collection().offset() / this.collection().limit()) + 1)
      },

      _initResizeNodesArr: function () {
        this._resizeNodesArr.clear();
        var firstNode = 20 + $(this.id()).cumulativeOffset().left + 1;
        //alert(firstNode);
        this._resizeNodesArr.push(firstNode);
        this._columns.inject(firstNode,
          function (acc, column) {
            acc = acc + column.width + 1;
            this._resizeNodesArr.push(acc);
            //alert(acc);
            return acc;
        }, this);
      },

      onDisplay: function () {
        if($(this.id())) {
          this.state().set($(this.id()).down('img.spinner') ? 'loadingDisplayed' : 'loadedDisplayed');
          this._initResizeNodesArr();
        }
      },
      
      onDrop: function (klass, conditions) {
        $(this.id()).removeClassName('draghover');
      },

      offset: function () {
        return this.collection().offset()
      },

      onTemplatesLoaded: function () {
        if(!this.loaded()) {this.checkLoaded();}
      },

      onMousedown: function (event) {
        Event.delegate({
          '.catalog-contents': function (event) { event.stop() } // used for preventing text selection ondrag - needed for selected dragging and dropping
        }).bind(this)(event)
      },

      checkLoaded: function () {
        if(this.collection().loaded()) { // FOR FUTURE: && this.templates().loaded()) {
          this._loaded = true;
        }
      },

      filters: function () {
        return this.widgets().get('filterSet');
      },

      selectDeselectRowFor: function (element) {
        var row
        row = element.up('.row');
        if(row) {
          if($F(element)) {
            row.addClassName('selected_row');
          } else {
            row.removeClassName('selected_row');
          }
        }
      },

      onCheckboxChange: function (element) {
        var row, dataId
        this.selectDeselectRowFor(element)
        row = element.up('.row');
        dataId = row.readAttribute('data-id');
        if($F(element)){
          this.selected().selectId(dataId);
        } else {
          this.selected().deselectId(dataId);
        }
        if(this.INNER){
          this.INNER(element)
        }
      },

      onChange: function (event) {
        Event.delegate({
          "input.check_all": function (event) {
            if($F(event.element())) {
              this.selected().selectAll();
            } else {
              this.selected().deselectAll();
            }
          },
          "input[type='checkbox']" : function (event) {
            this.onCheckboxChange(event.element());
          },
          '.filters' : function (event) {
            this.filters().onChange(event);
          }
        }).bind(this)(event);
      },

      onRowClick: function(event){

      },

      onClick: function(event) {
        Event.delegate({

          '.row td:not(.checkbox_cell):not(.move_controls)': function(event) {
            if(event.element().readAttribute('type')!='checkbox') {
              this.onRowClick(event);
            }
          },

          'th.attribute_name': function(event) {
            var order_on= event.element().upper('.attribute_name').getAttribute("data-id");
            if(order_on && order_on != '') {
              if(this.curr_order=='ascending') {
                this.collection().order(order_on+" DESC");
                this.curr_order='descending';
              }else{
                this.collection().order(order_on);
                this.curr_order='ascending';
              }
              this.curr_column=order_on;
              this.collection().load();
            }
          },

          '.checkbox_cell': function(event) {
            if (event.target){
              var me = this;
              me.shiftCheck(event).each(function(chk){
                me.onCheckboxChange(chk);
              });
            }
          },

          '.control': function(event) {
            if(!event.element().hasClassName('inactive')) {
              switch(event.element().innerHTML.unescapeHTML()) {
                case '|<': this.pageStart(); break;
                case '<<': this.pageLeft();  break;
                case '>>': this.pageRight(); break;
                case '>|': this.pageEnd();   break;
              }
            }
          },

          '.publifier': function (event){
            var page = this
              , projectId = params["project_id"]
              , path = params["controller"];
            var ids, action, success, confirmation;

            switch($('publifier_select').value){
              case 'Make Selected Public':
                ids          = $$('.selected_row').map(function(row){return row.down('input[type="checkbox"]').value}).join(',');
                action       = "make_public";
                success      = "Record(s) successfully made public.";
                confirmation = "Are you sure you want to make your selection publicly viewable?"
                break;
              case 'Make All Public':
                ids          = "all";
                action       = "make_all_public";
                success      = "Entire collection successfully made public.";
                confirmation = "Are you sure you want to make the entire collection publicly viewable?"
                break;
              case 'Make Selected Private':
                ids          = $$('.selected_row').map(function(row){return row.down('input[type="checkbox"]').value}).join(',');
                action       = "make_private";
                success      = "Record(s) no longer viewable by public.";
                confirmation = "Are you sure you want to make your selection not publicly viewable?";
                break;
              case 'Make All Private':
                ids          = "all";
                action       = "make_all_private";
                success      = "Entire collection is not viewable by public.";
                confirmation = "Are you sure you want to make the entire collection not publicly viewable?";
                break;
            }
            if (!ids.empty()){ if(confirm(confirmation)) publify(page,projectId,ids,path,action,success, function(){
              $$('.selected_row').each(function(row){
                //should unselect rows here
                //but need to handle molecular/seqs seperate selection
              })
            });} //lib/publifier.js
          },

          ".unselect": function (event){ this.selected().deselectAll(); }

        }).bind(this)(event);
      },

//      SINCE FILTER SET IS A WIDGET THIS DELEGATION TAKES PLACE AUTOMATICALLY - ChrisG
//      onSubmit: Event.delegate({
//        '.filters': function (event) {this.filters().onSubmit(event);}
//      }),

//      SINCE FILTER SET IS A WIDGET THIS DELEGATION TAKES PLACE AUTOMATICALLY - ChrisG
//      onMouseup: Event.delegate({
//        '.filters' : function (event) {this.filters().onMouseup(event);}
//      }),

      onMouseover: function(event) {
        //this.notifier().warning(event.element().tagName);
        if(this._inARow(event.element())) {
          event.element().up('tr[data-id]').addClassName('highlighted');
        }
      },
      onMouseout: function(event) {
        if(this._inARow(event.element())) {
          event.element().up('tr[data-id]').removeClassName('highlighted');
        }
      },

      pageEnd: function() {
        var count = this.collection().count() || parseInt($('collection_count').innerHTML, 10)  //always include the radix value in parseInt
        var page = (count / this.limit()).ceil()
        this.collection().offset((page - 1)*this.limit()).load()
      },
      getCount: function (ele) {
        //pagination text is always childNode[4], get the value, then eliminate leading/trailing whitespace
        var text = ele.childNodes[4].nodeValue.replace(/^\s+|\s+$/g,'').split(' ')
        var count = text[4]
        return count
      },
      pageLeft: function() {
        var page = this.page() - 1
        this.collection().offset((page - 1)*this.limit()).load();
      },

      pageRight: function() {
        var page = this.page() + 1
        this.collection().offset((page - 1)*this.limit()).load()
      },
      pageStart: function() {
        this.collection().offset(0).load();
      },

      _columnValue: function (item, column) {
        var value;
        if(column.moveControls) {
          value =
            ((item == Object.values(this.collection().entries().first()).first()) ?
              this.context().imageTag('uu_gray.png', { 'class': 'button moveTop inactive' })+
              this.context().imageTag('u_gray.png',  { 'class': 'button moveUp inactive' })
            : this.context().imageTag('uu.png',      { 'class': 'button moveTop active' })+
              this.context().imageTag('u.png',       { 'class': 'button moveUp active' })
            )+
            ((item == Object.values(this.collection().entries().last()).first()) ?
              this.context().imageTag('d_gray.png',  { 'class': 'button moveDown inactive' })+
              this.context().imageTag('dd_gray.png', { 'class': 'button moveBottom inactive' })
            : this.context().imageTag('d.png',       { 'class': 'button moveDown active' })+
              this.context().imageTag('dd.png',      { 'class': 'button moveBottom active' })
            );
        } else {
          value = this._nestedAttribute(item, column.attribute);
          if(column.type == 'date') {
            value = this._formatDate(value)
          }
        }
        return value;
      },

      _formatDate: function (raw) {
        var year, month, strMonth, day, hour, min, sec;
        var match = raw.match(/(\d{4})\-(\d{2})\-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z/);
        year  = match[1];
        month = match[2];
        day   = match[3];
        hour  = match[4];
        min   = match[5];
        sec   = match[6];
        switch(month) {
          case '01': strMonth = 'Jan';break;
          case '02': strMonth = 'Feb';break;
          case '03': strMonth = 'Mar';break;
          case '04': strMonth = 'Apr';break;
          case '05': strMonth = 'May';break;
          case '06': strMonth = 'Jun';break;
          case '07': strMonth = 'Jul';break;
          case '08': strMonth = 'Aug';break;
          case '09': strMonth = 'Sep';break;
          case '10': strMonth = 'Oct';break;
          case '11': strMonth = 'Nov';break;
          case '12': strMonth = 'Dec';break;
        }
        return ""+strMonth+" "+day+", "+year+" "+hour+":"+min+":"+sec+" UTC";
      },

      refreshContents: function () { this.renderTable(); },

      renderSpinner: function () {
        var catalog = $(this.id());
        var spinner = this._filler({ spinner: true, numOfDisplayed: 0 });
        catalog.down('.catalog-contents table').update(spinner);
        this.state().set('loadingDisplayed');
      },

      renderTable: function () {
        var me = this;
        this.context().templates().on('state:loaded', function () {
          var catalog = $(me.id());
          if (catalog) {
            catalog.down('.catalog-contents table').update(me._contents());
            catalog.down('.catalog-footer').down('.border').update(me._footerContents());
//            catalog.down('.catalog-footer').down('.border').update(me._counterNav());
            me.state().set('loadedDisplayed');
          }
        }, { once: true });
      },

      renderToString: function() {
//        if(this.collection().state().is('loading')) {
//          this.state().set('loading');
//        }
        var filters =
          (this.filters().renderToString && this.filters().renderToString()) ||
          (this.filters().render && this.filters().render())
        this.cycle().reset();
        var out = this.parent().templates().get('widgets/_catalog').evaluate({
          'raw action_panel':    (this.widget('actionPanel').renderToString && this.widget('actionPanel').renderToString())
                           || (this.widget('actionPanel').render && this.widget('actionPanel').render()),
          'raw filters':   filters ? "<tr><td>"+filters+"</td></tr>" : '',
          id:              this.id(),
          'raw column_headings': this._columnHeadings(),
          'raw counter_nav':     this._counterNav(),
          'raw contents':        this._contents(),
//          'raw public_actions':  this._publicActions(),
//          'raw private_actions': this._privateActions(),
          'raw publifier_control': this._publifierControl()
        });
        return out
      },

      _contents: function () {
        var out = '<table style="height: '+this.limit()+'px">'+this._entriesHTML()+this._filler()+'</table>'
        if(this.hasContentsForm()) {
          out = "<form id='list_items_form'><inpute type='hidden' name='conditions' value='" + this.selected().toString() + "'/>" + out + "</form>";
        }
        return out;
      },

      _columnHeadings: function () {
        var image="";
        var temp=this;
        if(this.curr_order=="ascending")
              image="<img src='/images/black_down_arrow.png' align='right'>";
        else
              image="<img src='/images/black_up_arrow.png' align='right'>";
        return this._columns.map(function(column) {
          var order_on;
          if(column.order_on)
            order_on=column.order_on;
          else
            order_on=column.attribute;
            if(temp.curr_column && temp.curr_column==order_on) {
              return "<th class='attribute_name' data-order='"+order_on+"' data-id='"+(column.order_on ? column.order_on : column.attribute) +"' style='width: " + column['width'] + "px'>" + (column.label || (column.attribute && column.attribute.gsub(/_/, " ").capitalize()) || '') + image+"</th>";
            } else {
              return "<th class='attribute_name' data-order='"+order_on+"' data-id='"+(column.order_on ? column.order_on : column.attribute) +"' style='width: " + column['width'] + "px'>" + (column.label || (column.attribute && column.attribute.gsub(/_/, " ").capitalize()) || '') +"</th>";
            }
        }).join('')
      },

      _entriesHTML: function () {
        var entriesHTML
          , entries = this.collection().data() && this.collection().entries();
        function tooltipify (string){if (!string.startsWith('<')) return (typeof(string) == 'string') ? string.split(/(.{0,60})/).join(' ').strip() : string;}
        if(entries && entries.size() > 0) {
          entriesHTML = entries.inject('', function(acc, item) {
            item = Object.values(item).first() // real attributes contained behind object type label
            var allClassNames = "sortable row ";
            if (this._excluding()){
              if (!this.selected()._ids.find(item[this._dataId])){
                allClassNames += "selected_row ";
              }
            }else{
              if (this.selected()._ids.find(item[this._dataId])){
                allClassNames += "selected_row ";
              }
            }
            allClassNames += this.cycle().toString();
            return acc + this.parent().templates().get('widgets/catalogs/_entry').evaluate({
              entry_class: allClassNames,
              //              entry_class: selectAllClassName + " " + (this.selected()._ids.find(item[this._dataId]) ? 'sortable row selected_row '+this.cycle().toString() : 'sortable row ' ) + this.cycle().toString(),
              data_id: item[this._dataId],
              entry: item,
              'raw checkbox_cell': this._checkboxCell(item),
              'raw column_data': this._columns.map(function(column) {
                var bgColor = column.attribute == 'color' ? "background-color: "+(this._columnValue(item, column) || '')+";" : '';
                var contents = column.attribute == 'color' ? '' : this._columnValue(item, column) || '';
                var cssClass = [
                  this._nestedAttribute(item, column.cssClass),
                  column.moveControls ? 'move_controls' : null
                ].compact().join(' ');

                return "<td style=\""+bgColor+"\"><div title=\"" + encodeURI(tooltipify(contents)) + "\" class=\""+cssClass+"\" style=\"width: "+(column.width-8)+"px\">"+contents+"</div></td>"; //.truncate((column.width-4) / 6)
              }.bind(this)).join('')
            });
          }.bind(this));
        } else {
          entriesHTML = '';
        }
        return entriesHTML;
      },

      _excluding: function(){return this.selected()._mode == "excluding" ? true : false},
      _including: function(){return this.selected()._mode == "including" ? true : false},

      _checkboxCell: function (item) {
        return("<div class='checkbox_cell'><input type='checkbox' name='data[]' value='"+item[this._dataId]+"'"+this._checked(item)+" /></div>");
      },

      _checked: function (item) {
        return( this._excluding() ? this.selected()._ids.find(item[this._dataId]) ? '' : 'checked' : this.selected()._ids.find(item[this._dataId]) ? 'checked' : '');
      },

      _filler: function (options) {
        var fillerText//, numOfDisplayed, fillerHeight;
        if(options) {
          if(!this.collection().data() || !this.collection().entries() || options.spinner) {
            fillerText = "<img class='spinner' src='/images/ajax-loader-large-alt.gif' />";
          } else if(this.collection().entries().size() === 0) {
            fillerText = this._emptyMsg;
          } else {
            fillerText = '';
          }
        }

        else {
          if(!this.collection().data() || !this.collection().entries()) {
            fillerText = "<img class='spinner' style='position:relative; top: 165px' src='/images/ajax-loader-large-alt.gif' />";
          } else if(this.collection().entries().size() === 0) {
            fillerText = this._emptyMsg
          } else {
            fillerText = '';
          }
        }

        return "<tr><td class='filler' colspan='"+(this._columns.size()+1)+"' style='height: 100%; text-align: center; vertical-align: middle'>"+fillerText+"</td></tr>"
      },
      _footerContents: function (){
        var output;
        output = "<table class=\"bottom\" style=\"width:100%;border:none;\">" +
          "<tr>" +
            "<td style=\"width:33%\">" + this._publifierControl() + "</td>" +
            "<td style=\"width:33%\">" + this._counterNav() + "</td>" +
            "<td style=\"width:33%\"></td>" +
          "</tr>" +
          "</table>"
        return output;
      },

      _publifierControl: function () {
        var actions = ["Make Selected Public", "Make All Public","Make Selected Private","Make All Private"];
        var selectOptions = actions.inject("", function(memo,action){
          memo += '<option value="' + action + '">'+action+'</option>'
          return memo;
        })
        return this.canPublify() ? '<select id="publifier_select" name="publifier_select">'+ selectOptions +'</select>' + "<input id=\"publifierButton\" class=\"publifier\" type=\"button\" value=\"Go\">" : "";
      },

      _counterNav: function () {
        var count = null, start = null, end = null, counter;
        count = this.collection().count();
        if(count || count === 0) {
          start = count > 0 ? this.collection().offset() + 1 : 0
          // start = (count > 0 && this.limit()) ? (this.page() - 1) * this.limit() + 1 : 1;
          end = (!this.collection().limit() || ((start + (this.collection().limit() - 1)) > count)) ? count : start + (this.collection().limit() - 1)
        }
        if((count || count===0) && (start || start===0) && (end || end===0)) {
          var leftActive, rightActive;
          leftActive = start > 1;
          rightActive = end < count;

          counter = "<span class='control"+(leftActive ? '' : ' inactive')+"'>|&lt;</span> " +
                    "<span class='control"+(leftActive ? '' : ' inactive')+"'>&lt;&lt;</span> " +
                    ""+start+" - "+end+" of "+count+" " +
                    "<span class='control"+(rightActive ? '' : ' inactive')+"'>&gt;&gt;</span> " +
                    "<span class='control"+(rightActive ? '' : ' inactive')+"'>&gt;|</span>";
        } else {
          counter = "<span class='control inactive'>|&lt;</span> " +
                    "<span class='control inactive'>&lt;&lt;</span> " +
                    "<span class='control inactive'>&gt;&gt;</span> " +
                    "<span class='control inactive'>&gt;|</span>";
        }
        return counter;
      },

      _inARow: function(element) {
        var row = element.up('tr[data-id]');
        return row && row.up('#' + this.id());
      },


      _nestedAttribute: function(object, attributePath) {
        return attributePath && attributePath.split('.').inject(object, function(acc, attribute) {
          return acc && acc[attribute];
        })
      },


      _toggleCheckbox: function(checkbox) {        
        if(checkbox) {          
          if(checkbox.getValue()) {
            checkbox.setValue(0);
          } else {
            checkbox.setValue(1);
          }
          return checkbox.getValue();
        }        
      },

      _selectArray: function () {
        return this.columns().map(function(col){return col.attribute}).concat(this.dataId());
      },

      showSelectionTools: function () {
        if ($('selected_tools')){
          var unselect = new Element('a', {'class': 'unselect'}).update("unselect");
          var view = new Element('a', {'class': 'view_selected'}).update('view'); //not using right now
          $('selected_tools').update("(" + unselect.outerHTML + ")");
        }
      },

      hideSelectionTools: function () {
        if ($('selected_tools')) $('selected_tools').update();
      },

      updateFormConditions: function () {
        $('selected_conditions').value = this.selected().toString();
      }
    }
  })
});
