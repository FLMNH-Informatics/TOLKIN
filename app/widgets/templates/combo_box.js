//= require <widget>
//= require <cycle>

Module('Templates', function () {
  JooseClass('ComboBox', {
    isa: Widget,
    has: {
      object:        { is: 'ro', required: true, nullable: false },
      method:        { is: 'ro', required: true, nullable: false },
      collection:    { is: 'ro', init: null },
      originalConditions: { is: 'ro', init: function () { return ( this._collection ? this._collection.where() : null )  } },
      collectionURI: { is: 'ro', init: null }, //required: true, nullable: false },
      width:         { is: 'ro', init: 225 },
      valueMethod:   { is: 'ro', nullable: false, init: 'id' },
      textMethod:    { is: 'ro', required: true, nullable: false },
      searchMethod:  { is: 'ro', required: true, nullable: false },
      resultsLimit:  { is: 'ro', init: 100 },
      options:       { is: 'ro', init: function () {return {}}},
      htmlOptions:   { is: 'ro', init: function () {return {}}},
      cycle:         { is: 'ro', lazy: true, init: function () {return new TOLJS.Cycle()}},
      editValue:     { },
      curScrollRegion: { },
      regionLoadDelay: { init: function () { return [ ] } },
      keyupDelay:    {},
      tagName:       { init: function () { return(
          this.object().meta.getClassObject().toString().split('.').pop().toLowerCase()+'['+
            [ this.method() ].flatten().first().singularize() + '_id][]')
          }
      }
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
          return method.inject(me.object().attributes(), function (obj, method_part) { return (obj[method_part] && Object.values(obj[method_part]).first()) }) // double method_part ugly but necessary due to json structure
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
        if(this.collection()) {
          this.collectionRequest({
            offset: num * this._resultsLimit,
            onSuccess: function () { me.renderRegion(num, me.collection().entries()) }
          })
        } else {
          var parameters = Object.extend(this.options().parameters, {
            offset: num * this._resultsLimit,
            limit: this._resultsLimit
          });
          if(this.where && this.where()) { parameters.conditions = this.where().toString() }
          new Ajax.Request(this.collectionURI().buildPath(params), {
            parameters: parameters,
            method: 'get',
            requestHeaders: {
              Accept: 'application/json'
            },
            onSuccess: function(transport) {
              me.renderRegion(num, transport.responseJSON[Object.keys(transport.responseJSON).detect(function(k){return !['count','limit','can_publify'].include(k) })]);
            }
          });
        }
      },

      collectionRequest: function (options) {
        this.collection().
          limit(this._resultsLimit).
          offset(options.offset || 0).
          where(null).
          where(this._originalConditions)
        if (options.conditions) { this.collection().where(options.conditions) }
        this.collection().load({ onSuccess: options.onSuccess })
      },

      

      searchtext: function () { var it; return (((it = (this._editValue || this.initObj())) && it[this._searchMethod]) || '') },
      trunctext:  function () { return this.fulltext().truncate((this._width - 25) / 8.5) },
      fulltext:   function () { var it; return (((it = (this._editValue || this.initObj())) && it[this._textMethod]) || '') },

      loadResults: function (search, keyupDelay) {
        var me = this
        if (this.collection()) {
          this.collectionRequest({
            conditions: search,
            onSuccess: function () {
              if(keyupDelay == me._keyupDelay) {
                me._buildScrollArray(me.collection().count())
                me.showResultsDropdown()
                me.showResults(me.collection().data())
                me.showArrow()
              }
            }
          })
        } else {
          var parameters = Object.extend(this.options().parameters, {
            limit: this._resultsLimit,
            offset: 0
          });

          if(this.where && this.where()) {
            parameters.conditions = this.where().and(search).toString()
          } else {
            parameters.conditions = search.toString()
          }
          new Ajax.Request(this.collectionURI().buildPath(params), {
            parameters: parameters,
            method: 'get',
            requestHeaders: {
              Accept: 'application/json'
            },
            onSuccess: function(transport) {

              var results = transport.responseJSON;
              if(keyupDelay == me._keyupDelay) {
                me._buildScrollArray(results.count);
                me.showResultsDropdown();
                me.showResults(results);
                me.showArrow();
              }
            }
          });
        }
      },

      onClick: function(event) {
        Event.delegate({
          '.text_field': function() {},
          '.box': function(event) {
            
            var dropdown = $(this.id()).down('.dropdown');
            var element = (event.element().up('.box') || event.element()).down('td.label');
            
            if(dropdown) {
              element.setStyle({
                paddingTop: '3px',
                paddingBottom: '3px',
                paddingRight: '0'
              });
              element.update(this.trunctext());
              this.hideResultsDropdown();
              this.showArrow();
            } else {
              element.setStyle({
                paddingTop: '0',
                paddingBottom: '0',
                paddingRight: '0'
              });
              this.showSpinner();
              element.update(
              "<input type='text' class='text_field' style='width:"+(this._width-40)+"px' id='"+this.id()+"_text_field' value='"+(element.readAttribute('data_searchtext')||'')+"' autocomplete='off' />"
              );
              $(this.id() + "_text_field").activate();
              var search = element.readAttribute('data_searchtext').split(' ').inject(null, function (acc, item) {
                if(acc) {
                  return acc.and(SyncRecord.attr(this._searchMethod).matches('%'+item+'%'))
                } else {
                  return SyncRecord.attr(this._searchMethod).matches('%'+item+'%')
                }
              }, this)
//              var search = SyncRecord.attr(this._searchMethod).matches('%'+element.readAttribute('data_searchtext')+'%')
//              search['search['+this._searchMethod+'_like]'] = (element.readAttribute('data_searchtext') || '');
              delete this._keyupDelay;
              this.loadResults(search);
            }
          },
          'li.option': function(event) {
            this._selectOption(event.element());
          }
        }).bind(this)(event);
      },

      _setValueWithElement: function (element) {
        this._editValue = {};
        this._editValue[this._valueMethod] = element.readAttribute('data-id');
        this._editValue[this._textMethod]  = element.readAttribute('data_fulltext');
        this._editValue[this._searchMethod] = element.readAttribute('data_searchtext');
        if (this._editValue[this._valueMethod] == null && this._editValue[this._textMethod] == null && this._editValue[this._searchMethod] == null){
          this._editValue  = null;
        }
      },

      _selectOption: function (optionElement) {
        this._setValueWithElement(optionElement);
        $(this.id()).down("input[type='hidden']").setValue(optionElement.readAttribute('data-id'));
      
        var element = $(this.id()).down("td.label");
        element.setStyle({
          paddingLeft: '10px',
          paddingTop: '3px',
          paddingBottom: '3px',
          paddingRight: '0'
        });
        this.context().mouseTooltip().hide();
        element.writeAttribute('data_searchtext', this.searchtext());
        element.writeAttribute('data_fulltext', this.fulltext());
        element.update(optionElement.innerHTML);
        this.toggleResultsDropdown();
      },

      onKeyup: function(event) {
//        Event.delegate({
//          '.text_field': function(event) {
        var me = this;
        clearTimeout(this._keyupDelay);
        var keyupDelay = setTimeout(function () {
          var search = $F(event.element()).split(' ').inject(null, function (acc, item) {
            if(acc) {
              return acc.and(SyncRecord.attr(me._searchMethod).matches('%'+item+'%'))
            } else {
              return SyncRecord.attr(me._searchMethod).matches('%'+item+'%')
            }
          }, this)
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

      showResults: function (toDisplay) {
        this.cycle().reset();
        var resultsElem = $(this.id()).down('.results');
        resultsElem.update(
          toDisplay[Object.keys(toDisplay).detect(function(k){return !['count','limit','can_publify'].include(k) })].inject("<li class='option #{cycle}'>None</li>".interpolate({
            cycle: this.cycle().toString()
          }), this._liElementText.bind(this))+
          this._spacers(Math.ceil(toDisplay.count/this._resultsLimit)-1)
        );
        resultsElem.scrollTop = 0;
        this._scrollArray[0] = true;
        this.onScroll();
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
        $(this.id()).down('.arrow-container').update("<img class='spinner' src='/images/ajax-loader.gif' width='14px' height='14px' />");
      },
      showArrow: function () {
        $(this.id()).down('.arrow-container').update("<img class='arrow' src='/images/black_down_arrow.png' />");
      },

      showResultsDropdown: function() {
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
           
            return this.parent().templates().get('widgets/_combo_box').evaluate({
              id:          this.id(),
              name:        this._tagName,
              value_label: value && value[this._textMethod].truncate((this._width+25)/ 8.5),
              value_fulltext:   value && value[this._textMethod],
              value_searchtext: value && value[this._searchMethod],
              value_id:    value && value[this.valueMethod()],
              box_style:   'width: '+this._width+'px'
            });
        }
      }
    }
  })
});
