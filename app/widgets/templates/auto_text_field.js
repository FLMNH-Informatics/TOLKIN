//= require <widget>
//= require <cycle>

Module('Templates', function () {
  JooseClass('AutoTextField', {
    isa: Widget,
    has: {
      object:        { is: 'ro', required: true, nullable: false },
      method:        { is: 'ro', required: true, nullable: false },
      collectionURI: { is: 'ro', required: true, nullable: false },
      width:         { is: 'ro', init: 225 },
      valueMethod:   { is: 'ro', required: true, nullable: false },
      textMethod:    { is: 'ro', required: true, nullable: false },
      searchMethod:  { is: 'ro', required: true, nullable: false },
      resultsLimit:  { is: 'ro', init: 100 },
      showDropdownFlag: { is: 'ro', init: false }, // used to tell whether should display fetched results when they are async returned or if dropdown should not show
      options:       { is: 'ro', init: function () {return {}}},
      htmlOptions:   { is: 'ro', init: function () {return {}}},
      cycle:         { is: 'ro', lazy: true, init: function () {return new TOLJS.Cycle()}},
      editValue:     { },
      objectName:    { is: 'ro', init: function () {
          return this.object().meta.getClassObject().toString().split('.').pop().toLowerCase();
      }},
      curScrollRegion: { },
      regionLoadDelay: { init: function () { return [ ] } }
    },
    override: {
      unload: function () {
        this.hideResultsDropdown();
        this.SUPER();
      }
    },
    methods: {

      initObj: function () {
        var me = this;
        var preValue = this.parent().interactMode() == 'browse' ? null : this._editValue; // only show stored yet unsaved edit value in edit mode
        return preValue || (function () {
          var method = [ me.method() ].flatten();
          return method.inject(me.object().attributes(), function (obj, method_part) { return obj[method_part] })
        })()
      },

      _sortBy: function (result) {
        return result[this.textMethod()]
      },

      _scrollRegion: function (scroll) {
        return Math.floor((scroll-26)/27/this._resultsLimit);
      },

      _resetRegionDelayedLoad: function (regionNum, loadDelayArr, ord) {
        var me = this;
        clearTimeout(loadDelayArr[ord]);
        if(this._scrollArray[regionNum] === false) { // only try to load current region if unloaded
          loadDelayArr[ord] = setTimeout(function () {
            me._scrollArray[regionNum] = true;
            me._loadRegion(regionNum);
          }, 500);
        }
      },

      _showMouseTooltip: function (event) {
        if(event.element().innerHTML.match(/\.{3}$/)) {
          var tooltip = this.context().mouseTooltip();
          tooltip.update(event.element().readAttribute('data_fulltext'));
          tooltip.show();
        }
      },

      onMouseover: function (event) {
        Event.delegate({
          'td.label' : this._showMouseTooltip,
          'li.option': this._showMouseTooltip
        }).bind(this)(event);
      },

      onMouseout: function (event) {
        Event.delegate({
          'td.label': function () {
            this.context().mouseTooltip().hide();
          },
          'li.option': function () {
            this.context().mouseTooltip().hide();
          }
        }).bind(this)(event);
      },

      onScroll: function () {
        var me = this;
        var scrollRegion = this._scrollRegion($(this.id()).down('.results').scrollTop);
        if(this._curScrollRegion != scrollRegion) { // only reset load delay timer on region switch
          this._resetRegionDelayedLoad(scrollRegion,   this._regionLoadDelay, 0);
          this._resetRegionDelayedLoad(scrollRegion-1, this._regionLoadDelay, 1);
          this._resetRegionDelayedLoad(scrollRegion+1, this._regionLoadDelay, 2);
        }
        this._curScrollRegion = scrollRegion;
//        if(scrollTop > this._scrollTrigger) {
//          alert('you be scrollin');
//          this._scrollTrigger = this._scrollTrigger + 1000;
//        }
      },

      _buildScrollArray: function (count) {
        this._scrollArray = [];
        Math.ceil(count/this._resultsLimit).times(function (i) {
          this._scrollArray[i] = false;
        }, this);
      },

      _loadRegion: function (num) {
        var me = this;
        this.showSpinner();
        var parameters = Object.extend(this.options().parameters, {
          offset: num * this._resultsLimit,
          limit: this._resultsLimit
        });
        if(this.where && this.where()) { parameters.conditions = this.where().toString() }
        new Ajax.Request(this.route(this.collectionURI()), {
          parameters: parameters,
          method: 'get',
          requestHeaders: {
            Accept: 'application/json'
          },
          onSuccess: function(transport) {
            //reject everthing except object   was transport.responseJSON.requested
            me.renderRegion(num, transport.responseJSON[me.getKey(transport.responseJSON)]);
          }
        });
      },

      searchtext: function () { var it; return (((it = (this._editValue || this.initObj())) && it[this._searchMethod]) || '') },
      trunctext:  function () { return this.fulltext().truncate((this._width - 25) / 8.5) },
      fulltext:   function () { var it; return (((it = (this._editValue || this.initObj())) && it[this._textMethod]) || '') },

      loadResults: function (search, keyupDelay) {
        var me = this;
        var parameters = Object.extend(this.options().parameters, {
          limit: this._resultsLimit,
          offset: 0
        });

        if(this.where && this.where()) {
          parameters.conditions = this.where().and(search).toString()
        } else {
          parameters.conditions = search.toString()
        }
//        parameters = Object.extend(parameters, options);
        new Ajax.Request(this.route(this.collectionURI()), {
          parameters: parameters,
          method: 'get',
          requestHeaders: {
            Accept: 'application/json'
          },
          onSuccess: function(transport) {

            var results = transport.responseJSON;
            if(keyupDelay == me._keyupDelay) {
              //comboBox._index = new TOLJS.StringIndex({array: results.requested, indexAttrLabel: comboBox.textMethod(), levelsDeep: 3});
              me._buildScrollArray(results.count);
              if(me._showDropdownFlag) {
                me.showResultsDropdown()
                me.showResults(results)
              }
              me.showArrow()
            }
            //comboBox.searchAndShowResults($F($(comboBox.id()).down('.text_field')));
          }
        });
      },

      onClick: function(event) {
        Event.delegate({
          '.text_field': function() {},
          '.box': function(event) {
            this._showDropdownFlag = true
            var dropdown = $(this.id()).down('.dropdown');
            //var element = (event.element().up('.box') || event.element()).down('td.label');
            var element = $(this.objectName()+ '_' + this.method()+ '_' + this.textMethod()+'_auto_input')
            if(dropdown) {
//              element.setStyle({
//                paddingTop: '3px',
//                paddingBottom: '3px',
//                paddingRight: '0'
//              });
              //element.update(this.trunctext());
              this.hideResultsDropdown();
              this.showArrow();
            } else {
//              element.setStyle({
//                paddingTop: '0',
//                paddingBottom: '0',
//                paddingRight: '0'
//              });
              this.showSpinner();
//              element.update(
//              "<input type='text' class='text_field' style='width:"+(this._width-40)+"px' id='"+this.id()+"_text_field' value='"+(element.readAttribute('data_searchtext')||'')+"' autocomplete='off' />"
//              );
              $(this.id()).down(".text_field").activate();

              //var search = SyncRecord.attr(this._searchMethod).matches('%'+element.readAttribute('data_searchtext')+'%')
              var search = SyncRecord.attr(this._searchMethod).matches('%'+$F(element)+'%')
//              search['search['+this._searchMethod+'_like]'] = (element.readAttribute('data_searchtext') || '');
              delete this._keyupDelay;
              this.loadResults(search);
            }
          },
          'li.option': function(event) {
            this._selectOption(event.element());
          },
          'td.arrow-container': function(event) {
            if (this._id == "viewport_window_morphology_matrices_matrix_name_from_auto_text_field"){
              new Ajax.Updater('from_matrix_version_select', '/projects/' + PROJECT_ID + '/morphology/matrices/select_for_branch_version',
              {
                method: 'get',
                parameters: {
                  branch_name: event.element().up(2).down('input').getValue()
                }
              })
            }
            else if (this._id == "viewport_window_morphology_matrices_matrix_name_auto_text_field") {
              new Ajax.Updater('to_matrix_version_select', '/projects/' + PROJECT_ID + '/morphology/matrices/select_for_branch_version',
              {
                method: 'get',
                parameters: {
                  branch_name: event.element().up(2).down('input').getValue()
                }
              })
            }
          }
        }).bind(this)(event);
      },

      _setValueWithElement: function (element) {
        this._editValue = {};
        this._editValue[this._valueMethod] = element.readAttribute('data-id');
        this._editValue[this._textMethod]  = element.readAttribute('data_fulltext');
        this._editValue[this._searchMethod] = element.readAttribute('data_searchtext');
      },

      _selectOption: function (optionElement) {
        this._setValueWithElement(optionElement);
        $(this.id()).down("input[type='hidden']").setValue(optionElement.readAttribute('data-id'));
        var element = $(this.id()).down('input[type="text"]');
//        element.setStyle({
//          paddingLeft: '10px',
//          paddingTop: '3px',
//          paddingBottom: '3px',
//          paddingRight: '0'
//        });
        //if a matrix, get version
        if (optionElement.up(6).readAttribute('id') == "viewport_window_morphology_matrices_matrix_name_from_auto_text_field") {
          new Ajax.Updater('from_matrix_version_select', '/projects/' + PROJECT_ID + '/morphology/matrices/select_for_branch_version',
            {
              method: 'get',
              parameters: {
                branch_name: optionElement.readAttribute('data-id') == null ? optionElement.up(5).previousElementSibling.down(3).getValue() : optionElement.readAttribute('data-id')
              }
            })
        }
         if (optionElement.up(6).readAttribute('id') == "viewport_window_morphology_matrices_matrix_name_auto_text_field") {
          new Ajax.Updater('to_matrix_version_select', '/projects/' + PROJECT_ID + '/morphology/matrices/select_for_branch_version',
            {
              method: 'get',
              parameters: {
                //branch_name: optionElement.readAttribute('data-id')
                branch_name: optionElement.readAttribute('data-id') == null ? optionElement.up(5).previousElementSibling.down(3).getValue() : optionElement.readAttribute('data-id')
              }
            })
        }
        this.context().mouseTooltip().hide();
        if(!this.fulltext().blank()) {
          element.writeAttribute('data_searchtext', this.searchtext());
          element.writeAttribute('data_fulltext', this.fulltext());
          element.setValue(this.fulltext());
        }
        this.toggleResultsDropdown();
      },

      onKeyup: function(event) {
        this._showDropdownFlag = true
//        Event.delegate({
//          '.text_field': function(event) {
        var me = this;
        clearTimeout(this._keyupDelay);
        var keyupDelay = setTimeout(function () {
          var search = SyncRecord.attr(me._searchMethod).matches('%'+$F(event.element())+'%')
//          search['search['+me._searchMethod+'_like]'] = $F(event.element());
          // THIS ISNT RIGHT - FIX ME

          me.loadResults(search, keyupDelay);
          me.showSpinner();
        }, 500);
        this._keyupDelay = keyupDelay;
//          }
//        }).bind(this)(event);
      },

//      onKeyup: function(event) {
//        Event.delegate({
//          '.text_field': function(event) {
//            this.searchAndShowResults($F(event.element()));
//          }
//        }).bind(this)(event);
//      },

      hideResultsDropdown: function() {
        var meElem, dropdownElem;
        if((meElem = $(this.id()))) {
          if((dropdownElem = meElem.down('.dropdown'))){
            Event.stopObserving($(this.id()).down('.results'), 'scroll');
            dropdownElem.remove();
          }
        }
        this._showDropdownFlag = false
      },

      renderRegion: function (regionNum, results) {
        this.cycle().reset();
        if(this._scrollArray[regionNum] == true) {
          var it;
          (it = $(this.id()).down('.results')) &&
          (it = it.down('li[data-ordinal="'+regionNum+'"]')) &&
          it.replace(
            results.inject('', this._liElementText.bind(this))
          );
        }
        this.showArrow();
      },

      _liElementText: function (acc, result) {
        result = Object.values(result).first(); // remove heading for item
        return acc + "<li data-id='#{id}' data_searchtext='#{searchtext}' data_fulltext='#{fulltext}' class='option #{cycle}#{cssClass}'>#{label}</li>".interpolate({
          id         : result[this._valueMethod],
          label      : result[this._textMethod].truncate((this._width - 25) / 8.5),
          searchtext : result[this._searchMethod],
          fulltext   : result[this._textMethod],
          cssClass   : (!result['css_class'] || result['css_class'].blank() ? '' : ' '+result['css_class']),
          cycle      : this.cycle().toString()
        });
      },

      //gets key of JSON response object
      getKey: function (retObj){
        var keys = Object.keys(retObj);
        var key = '';
        keys.each(function(v){
           if(v != 'count' && v != 'limit'){
             key = v;
           }
        });
        return key;
      },

      showResults: function (toDisplay) {
        if ($(this.id())) {
          this.cycle().reset();
          var resultsElem = $(this.id()).down('.results');
          resultsElem.update(
            toDisplay[this.getKey(toDisplay)].inject("<li class='option #{cycle}'>None</li>".interpolate({
              cycle: this.cycle().toString()
            }), this._liElementText.bind(this))+
            this._spacers(Math.ceil(toDisplay.count/this._resultsLimit)-1)
          );
          resultsElem.scrollTop = 0;
          this._scrollArray[0] = true;
          this.onScroll();
        }
      },

      _spacers: function (count) {
        var out = '';
        count.times(function (i) {
          var height = (27 * ((i < count - 1) ? this._resultsLimit : (count % this._resultsLimit))) - 12;
          out += "<li class='spacer' data-ordinal='"+(i+1)+"' style='height:"+height+"px'></li>";
        }, this);
        return out;
      },

//      searchAndShowResults: function(term) {
//        var results = this._index.search(term).sortBy(this._sortBy, this);
//        this.cycle().reset();
//        $(this.id()).down('.results').update(
//          results.inject("<li class='#{cycle}'>None</li>".interpolate({
//            cycle: this.cycle().toString()
//          }),function(acc, result) {
//            return acc + "<li data-id='#{id}' class='#{cycle}'>#{label}</li>".interpolate({
//              id: result.id,
//              label: result[this.textMethod()],
//              cycle: this.cycle().toString()
//            });
//          }.bind(this))
//          );
//      },

      showSpinner: function () {
        if ($(this.id())) $(this.id()).down('.arrow-container').update("<img class='spinner' src='/images/ajax-loader.gif' width='14px' height='14px' />");
      },
      showArrow: function () {
        if ($(this.id())) $(this.id()).down('.arrow-container').update("<img class='arrow' src='/images/black_down_arrow.png' />");
      },

      showResultsDropdown: function() {
        if ($(this.id())) {
          var results = $(this.id()).down('.dropdown');
          if(results) {
            results.show();
          } else {
            var boxOffset = $(this.id()).down('.box').positionedOffset();
  //          alert('left: ' + boxOffset.left + ' top:' + boxOffset.top);
            $(this.id()).insert({
              bottom: "<div class='dropdown' style='left:#{left};top:#{top}'><table style='width:#{width}px'><tr><td class='results_TD' colspan='2'><ul class='results'></ul></td></tr></table></div>".interpolate({
                id: this.id() + '_text_field',
                left: boxOffset.left,
                top: boxOffset.top + 40,
                width: this._width
              })
            });
            var resultsElem = $(this.id()).down('.results');
            Event.observe(resultsElem, 'scroll', this.onScroll.bind(this));
          }
        }
      },

      toggleResultsDropdown: function() {
        var results = $(this.id()).down('.dropdown');
        if(results && results.visible()) {
          this.hideResultsDropdown();
        } else {
          this.showResultsDropdown();
        }
      },

      render: function () {
        return this.renderToString();
      },

      renderToString: function() {
        var out, value;
        value = this.initObj();
        switch(this.parent().interactMode().toString()) {
          case 'browse':
            if(!value || value[this.textMethod()].strip() == '') {
              out = "<span class='empty'>None</span>";
            } else {
              out = "<span class='link' data-id='" + value[this.valueMethod()] + "'>" + value[this.textMethod()] + "</span>";
            }
            return out;
          case 'edit'  :
            return this.parent().templates().get('widgets/_auto_text_field').evaluate({
              id:          this.id(),
              name:        this._objectName+'['+this._method+'_'+this._valueMethod+']',
//              value_label: value && value[this._textMethod].truncate((this._width+25)/ 8.5),
//              "<input type='text' class='text_field' style='width:"+(this._width-40)+"px' id='"+this.id()+"_text_field' value='"+(element.readAttribute('data_searchtext')||'')+"' autocomplete='off' />"
              value_fulltext:   value && value[this._textMethod],
              value_searchtext: value && value[this._searchMethod],
              text_field_style: "width:"+(this._width-40)+"px",
              text_field_name: this._objectName+'['+this._method+'_'+this._textMethod+']',
              text_field_value: (value && value[this._searchMethod])||'',
              value_id:    value && value[this.valueMethod()],
              box_style:   'width: '+this._width+'px'
            });
        }
      }
    }
  })
});
