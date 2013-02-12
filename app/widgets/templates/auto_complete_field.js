//= require <widget>
//= require <cycle>

Module('Templates', function () {
  JooseClass('AutoCompleteField', {
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
//       searchMethod:  { is: 'ro', required: true, nullable: false },
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
    after: {
      initialize: function () {
        this.handlers().push(
          this.frame().on('state:displayed', function () {
            this._focusHandler = this.element().down('input[type="text"]').on('focus', this.onFocus.bind(this))
            this._blurHandler = this.element().down('input[type="text"]').on('blur', this.onBlur.bind(this)) 
          }, this)
        )
      }
    },
    override: {
      unload: function () {
        if(this._blurHandler) {
          this._blurHandler.stop()
          delete this._blurHandler
        }
        if(this._focusHandler) {
          this._focusHandler.stop()
          delete this._focusHandler
        }
        this.hideResultsDropdown()
        this.SUPER()
      }
    },
    methods: {
      textFieldElement: function () {
        return this.element().down('input[type="text"]')
      },

      onFocus: function () {
        this.textFieldElement().activate()
      },

      onBlur: function () {
        setTimeout(function () {
            this.hideResultsDropdown()
            this.showArrow()
        }.bind(this), 125)
      },

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
          'li.option': function () { 
            var highlightedEl = this.highlightedOptionElement()
            if (highlightedEl) { highlightedEl.removeClassName('highlighted') }
            event.element().upper('li.option').addClassName('highlighted')
            this._showMouseTooltip(event)
          }
        }).call(this, event)
      },

      onMouseout: function (event) {
        Event.delegate({
          'td.label': function () {
            this.context().mouseTooltip().hide();
          },
          'li.option': function () {
            var highlightedEl = this.highlightedOptionElement()
            if (highlightedEl) { highlightedEl.removeClassName('highlighted') }
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

      

//      searchtext: function () { var it; return (((it = (this._editValue || this.initObj())) && it[this._searchMethod]) || '') },
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
              var search = $F($(this.id()).down('input[type="text"]')).split(' ').inject(null, function (acc, item) {
                if(acc) {
                  return acc.and(SyncRecord.attr(this._textMethod).matches('%'+item+'%'))
                } else {
                  return SyncRecord.attr(this._textMethod).matches('%'+item+'%')
                }
              }, this)
              delete this._keyupDelay;
              this.loadResults(search);
            }
          },
          'li.option': function(event) {
            this._selectOption(event.element().upper('.option'))
          }
        }).bind(this)(event);
      },

//       _setValueWithElement: function (element) {
//         this._editValue = {};
//         this._editValue[this._valueMethod] = element.readAttribute('data-id');
//         this._editValue[this._textMethod]  = element.readAttribute('data_text');
// //         this._editValue[this._searchMethod] = element.readAttribute('data_searchtext');
//       },

      _selectOption: function (optionElement) {
        this.context().mouseTooltip().hide();
        this.textFieldElement().setValue(optionElement.readAttribute('data-text'))
        this.toggleResultsDropdown();
      },

      highlightedOptionElement: function () {
        return this.element().down('.option.highlighted')
      },

      onKeyPressArrowUp: function () {
        var curOptionEl = this.highlightedOptionElement()
        if(curOptionEl) {
          var prevOptionEl = curOptionEl.previous('.option')
          curOptionEl.removeClassName('highlighted')
          if(prevOptionEl) {
            prevOptionEl.addClassName('highlighted')
          }
        }
      },

      onKeyPressArrowDown: function () {
        var curOptionEl = this.highlightedOptionElement()
        if(curOptionEl) {
          var nextOptionEl = curOptionEl.next('.option')
          if(nextOptionEl) {
            curOptionEl.removeClassName('highlighted')
            nextOptionEl.addClassName('highlighted')
          }
        } else {
          if (this.element().down('.option:first-child')) { this.element().down('.option:first-child').addClassName('highlighted') }
        }
      },

      onKeyPressEnter: function (event) {
        var curOptionEl = this.highlightedOptionElement()
        if(curOptionEl) {
          event.stop()
          this._selectOption(curOptionEl) 
        }
      },

      onKeyup: function(event) {
        switch (event.keyCode) {
        case 13:
          this.onKeyPressEnter(event)
          break
        case 38:
          this.onKeyPressArrowUp()
          break
        case 40:
          this.onKeyPressArrowDown()
          break
        default:
          var me = this;
          clearTimeout(this._keyupDelay);
          var keyupDelay = setTimeout(function () {
            var search = $F(event.element()).split(' ').inject(null, function (acc, item) {
              if(acc) {
                return acc.and(SyncRecord.attr(me._textMethod).matches('%'+item+'%'))
              } else {
                return SyncRecord.attr(me._textMethod).matches('%'+item+'%')
              }
            }, this)
            me.loadResults(search, keyupDelay);
            me.showSpinner();
          }, 500);
          this._keyupDelay = keyupDelay;
          break
        }
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
       
        return acc + "<li data-id='#{id}' data-text='#{text}' class='option #{cycle}#{cssClass}'>#{text}</li>".interpolate({
          id         : result[this._valueMethod],
//           label      : result[this._textMethod].truncate((this._width - 25) / 8.5),
//           searchtext : result[this._searchMethod],
          text   : result[this._textMethod],
          cssClass   : (!result['css_class'] || result['css_class'].blank() ? '' : ' '+result['css_class']),
          cycle      : this.cycle().toString()
        });
      },

      showResults: function (toDisplay) {
        this.cycle().reset();
        var resultsElem = $(this.id()).down('.results');
        resultsElem.update(
          toDisplay[Object.keys(toDisplay).detect(function(k){return !['count','limit','can_publify'].include(k) })].inject("<li class='option "+this.cycle().toString()+"'>None</li>", this._liElementText.bind(this))+
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
        $(this.id()).down('.arrow-container').update('<input type="button" style="background-image: url(/images/black_down_arrow.png);width:21px;height:21px;background-repeat:no-repeat;background-position:45%" />')
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
            return this.parent().templates().get('widgets/_auto_text_field').evaluate({
              id:          this.id(),
              name:        this._tagName,
              value_label: value && value[this._textMethod].truncate((this._width+25)/ 8.5),
              value_fulltext:   value && value[this._textMethod],
//               value_searchtext: value && value[this._searchMethod],
              text_field_style: "width:"+(this._width-40)+"px",
              text_field_name: this._objectName+'['+this._method+'_'+this._textMethod+']',
              text_field_value: (value && value[this._textMethod])||'',
              value_id:    value && value[this.valueMethod()],
              box_style:   'width: '+this._width+'px'
            });
        }
      }
    }
  })
});
