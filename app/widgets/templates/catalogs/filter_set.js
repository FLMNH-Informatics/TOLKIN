//= require <widget>
//= require <roles/fires_events>
//= require <roles/polling>
//= require <state>

JooseModule('Templates.Catalogs', function() {
  JooseClass('FilterSet', {
    isa: Widget,
    does: [ Roles.FiresEvents, Polling ],
    has: {
      col_id: { init: null, required: false },
      filters:     { init: null },
      textBoxSize: { init: 30 },
      //id:          { is: 'ro', init: function () { return ''+this.catalog().id()+'_filters' }},
      catalog:     { is: 'ro', required: true, nullable: false },
      state: { is: 'ro', init: function () { return new State([
        [ 'unrendered', 'rendered' ],
        [ 'renderedOptionsLoading', 'renderedOptionsLoaded' ]
      ], this) } }
    },
    after: {
      initialize: function () {
        this.state().set($(this.id()) ? 'rendered' : 'unrendered');
      }
    },
    methods: {
//      receiveMessage: function (msg) {
//        if(msg.inheritsFrom(Events.Loaded) && msg.sender === this) {
//          this.render();
//        }
//      },

      setSaveSearchFields: function(){
        if(params.hasOwnProperty('tag')){
          $('tag_name').value = params['tag']['name'];
          $('tag_save').checked = params['tag']['save'];
        }
      },

      load: function () {
        this.getFilters();
      },

      removeFilterRow: function (event) {
        var optionValue = event.element().id.sub('fv_', '');
        $(this.id()).down('select').descendants().each(function (element) {
          if(optionValue == element.readAttribute('value')) {
            element.disabled = false; //how can we return from this block at this point. i.e. it need to return from each too.
          }
        });
        event.element().up('tr').remove();
      },

      onClick: function (event) {
          var me = this;
          Event.delegate({
              '.visibility-toggle': function () {
                  $(this.id()).down('.container').toggle();
              },
              '.button.active': function (event) {
                  switch(event.element().upper('.button').readAttribute('value')) {
                      case 'x':
                          me.removeFilterRow(event);
                  }
              },
            'input[type="submit"]' :  function () {
              event.stop()
              var form = event.element().up('form')
              me.setCollectionOptions(form.serialize({ hash: true, submit: false }))
              me.catalog().collection().load()
              this.catalog().selected().deselectAll()
            }
          }).bind(this)(event)
      },

      getFilters: function(){
        var me = this;
        var filters = this;
        var url = '/filters/';
        new Ajax.Request( url, {
          parameters : {
            model_name :
              filters.catalog().collection().type().meta.className().split('.').join('::')
          },
          //requestHeaders : [ "Accept", "application/json" ],
          method : 'get',
          onSuccess : function(transport) {
            if(transport.responseJSON) {
              me._filters = transport.responseJSON.filters;
              if(me.catalog().state().not('notDisplayed') && me.state().is('renderedOptionsLoading')) { me.render(); }
            }
          }
        });
      },
      renderSearchFieldsFromParams: function(){
        var fview = this, option, range_param;
        var property;
        this.setSaveSearchFields();
        $H(params['search'] || {} ).each(function(searchCond){
//          if(searchCond.key.endsWith('_like')){
//            property = searchCond.key.sub('_like', '')
//          }
//          else if(searchCond.key.endsWith('_gte')){
//            property = searchCond.key.sub('_gte', '')
//            range_param = searchCond.key;
//          }
//          else if(searchCond.key.endsWith('_lte')){
//            property = searchCond.key.sub('_lte', '')
//            range_param = searchCond.key;
//          }
//          else{
//            throw 'unhandled search param';
//          }
          option = $(fview._filterId).select('option[value="'+ searchCond.key/*property*/  + '"]').first()
          fview.handleSelection(option, searchCond.value, range_param);
        })
      },
      render: function () {
        $(this.id()).replace(this.renderToString());
//        this.renderSearchFieldsFromParams();
      },
      renderToString: function () {
        return this.context().templates().get('filters/_form').evaluate({
          id:             this.id(),
          select_options: this._selectOptions(),
          filter_rows:    this._filterRows()
        });
      },

      _filterRows: function () {
        return $H(this.catalog().collection().searchParams() || {}).collect(function (pair) {
          var name = pair.key;
//          var name = pair.key.match(/^\w+\[(\w+)\]$/)[1];
          name = name.sub(/_like$/, '');
          var filter = this._filters[name];
          while(!filter && name != '_id') {
            name = name.sub(/_?[A-Za-z]+(_id)?$/, '_id');
            filter = this._filters[name];
          }
          return this._filterRow(filter, pair.value);
        }, this).join("")
      },

      _selectOptions: function () {
        if(this._filters) {
          this.state().set('renderedOptionsLoaded');
          return this._filtersHTML();
        } else {
          this.state().set('renderedOptionsLoading');
          return "<option selected='selected'>loading filters...</option>"
        }
      },

      _filtersHTML : function() {
        var flag=false;
        var utility = this;
        var items = $H(this._filters).values();
        var renderString = "<option value=''>Select Filter</option>";
        items.each (function(item){
          utility._filters[item.name] = item;
            if(utility.catalog().collection().searchParams() &&
              utility.catalog().collection().searchParams()["search["+item['name']+"]"]!=undefined){
                flag=true;
            }
          var item_label = item['label'] || item['name'].humanize();
          renderString +=
            "<option data-field-type='"+
            item['type']+"' value="+item['name'].toString()+
            (flag ? " disabled='disabled'" : '')+">"+
            item_label+
            "</option>"
          flag=false;
        });
        return renderString;
      },

      _filterRow: function(filter, term) {
        term = term || '';
//        default_value = default_value || '';
//        if('' == option.value){
//          return;
//        }
        var filter_label = filter.label || filter.name.humanize();
        var str, str_name, row;
        if(filter.name.endsWith("_id")){
          str = filter.name.strip().underscore().gsub(' ', '_').gsub('_id', '');
          str_name = (filter.name == 'namestatus_id' ? 'namestatuses.status' : (str + '.name'));
//          row = "<tr><td id='fv_"+filter.name+"' size='3'>x</td><td><label>"+filter_label+"</label></td><td><input type='text' size='"+this._textBoxSize+"' name='search["+str_name+"]' value='"+term+"' /></td></tr>";
//       } else if (filter['type'] == "integer"){
          // WHERE IS THIS BEING USED?
//          str = filter.name.strip().underscore().gsub(' ', '_');
//          str_name = str;
//          if($('fv_'+filter.name)){
//            $('search_'+range_param).writeAttribute('value', '')
//          }else{
//            row = "<tr><td><input type='button' class='button active' value='x' id='fv_"+filter.name+"' value='x'></td><td><label for='search_"+str+"'>"+filter_label+" Range</label></td><td><input type='text' size='"+this._textBoxSize/2+"' name='search["+ str_name +"_gte]'"
//            row = row + "value=''"
//            row = row + "id='search_"+ str_name +"_gte'/>-<input type='text' size='"+this._textBoxSize/2+"' name='search["+ str_name +"_lte]' "
//            row = row + "value=''"
//            row = row + " id='search_"+ str_name +"_lte'/></td></tr>";
//          }
//        }
        } else {
          str = filter.name.strip().underscore().gsub(' ', '_');
          str_name = str;//+"_like";
//          row = "<tr><td><input type='button' class='button active' value='x' id='fv_"+filter.name+"' value='x'></td><td><label>"+filter_label+"</label></td><td><input type='text' size='"+this._textBoxSize+"' name='search["+ str_name +"_like]' value='"+term+"' /></td></tr>";
        }
        row = "\
          <tr>\n\
            <td>\n\
              <input type='button' class='button active' value='x' id='fv_"+filter.name+"' value='x'>\n\
            </td>\n\
            <td style='width:10px'></td>\n\
            <td><label>"+filter_label+"</label></td>\n\
            <td>" + (filter.name == 'namestatus_id' ? filter.input : "<input type='text' size='"+this._textBoxSize+"' name='search["+str_name+"]' value='"+term+"' />") + "</td>\n\
          </tr>";
        return row;
      },

      //onSubmit: function(event) {
      //  event.stop();
      //  this.setCollectionOptions(event.element().serialize({ hash: true, submit: false }))
      //  this.catalog().collection().load()
      //},

      setCollectionOptions: function (formHash) {
        var cOptions = this.catalog().collection().finderOptions()
        cOptions.clearConditions({recursive: true}).offset = 0 // FIXME: ugly and artificial - clear where conditions from previous search
        $H(formHash).each(function(pair) {
          //don't add to conditions if value is blank string
          if(!pair.value.blank()){
            var attrName = pair.key.match(/search\[([\w\.]+)\]/)[1]
            var newCond =
              pair.value.split(/\s+/).inject(null, function (acc, item) {
                //TODO:  Make this work for all _id attributes
                 var toAdd = SyncRecord.attr(attrName)._name == "namestatus_id" ? SyncRecord.attr(attrName).eq(item) : SyncRecord.attr(attrName).matches('%'+item+'%')
                 return ( acc ? acc.and(toAdd) : toAdd )
              }, this)
  //           SyncRecord.attr(attrName).matches('%'+pair.value+'%')
            cOptions.conditions = cOptions.conditions ? cOptions.conditions.and(newCond) : newCond
          }
        })
        
      },

      // events
      onChange: function(event) {
        Event.delegate({
          'select[name=filter_select]': function(event) {
            var select = event.element();
            var option = select.childElements()[select.selectedIndex];
            if(select.selectedIndex != 0) { // 'Select Filter' option is select if index is 0
              option.writeAttribute("disabled" , "disabled");
              //alert(this._filters[option.value]);
              if(this._filters) {
                var filterRow = this._filterRow(this._filters[option.value]);
                var new_row = $(this.id()).down('.container > tbody').insert(filterRow);
                if (new_row.down('select') && option.value == "namestatus_id") new_row.down('select').writeAttribute({name: 'search[namestatus_id]'}).setStyle({width: '324px'})
              } else {
                $(this.id()).down('.container > tbody').insert("<tr class='"+option.value+"_filter_row'><td colspan='4'>loading filter info ...</td></tr>")
                this.poll({
                  on: function () { return this._filters },
                  run: function () {
                    var filterRow = this._filterRow(this._filters[option.value])
                    var new_row = $(this.id()).down('.container > tbody').down('.'+option.value+'_filter_row').replace(filterRow)
                    if (new_row.down('select') && option.value == "namestatus_id") new_row.down('select').writeAttribute({name: 'search[namestatus_id]'}).setStyle({width: '324px'})
                  }
                })
              }
              select.childElements()[0].selected = true;
            }
          }
        }).bind(this)(event);
      }//,
//      onMouseup: function(event) {
//        Event.delegate({
//          '.toggle_show' : function () {
//            $(this.id()).down('.container').toggle();
//          }//,
////          '.close': function(){
////            var optionValue = event.element().id.sub('fv_', '');
////            $(this.id()).down('select').descendants().each(function (element) {
////              if(optionValue == element.readAttribute('value')) {
////                element.disabled = false; //how can we return from this block at this point. i.e. it need to return from each too.
////              }
////            });
////            event.element().up('tr').remove();
////          }
//        }).bind(this)(event);
//      }
    }
  })
});
