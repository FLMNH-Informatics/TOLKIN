//= require <templates/tooltip>

Module('Matrices.Datagrids', function () {
  JooseClass('Observer', {
    has: {
      datagrid: { is: 'ro', required: true, nullable: false },
      tooltip:  { is: 'ro', init: function () { return new Templates.Tooltip({ parent: this.datagrid() }) }},
      selectedRow:      { is: 'rw', init: null  },
      selectedCol:      { is: 'rw', init: null  }
    },
    after: {
      initialize: function () {
        var observer = this;
        Event.observe('table_body_container', 'scroll', function(event) {
          $('table_head_container').scrollLeft = $('table_body_container').scrollLeft;
        });
        if(this.datagrid().type() != 'molecular') {
//          Event.observe('table_body_container', 'mouseleave', function(event) {
          Event.observe('table_body', 'mouseleave', function(event) {
            $('table_body_container').stopObserving('mousemove');
            observer.tooltip().hide();
            if (!observer.datagrid()._quickEditModeOn) $('state_display_list').innerHTML = "";
          });
//          Event.observe('table_body_container', 'mouseenter', function(event) {
          Event.observe('table_body', 'mouseenter', function(event) {
            $('table_body_container').observe('mousemove', function(event) {
              observer.tooltip().move(event.pointer());
            });
            observer.tooltip().show();
          });

          Event.observe('table_body', 'mouseover', function(event) {
            var hoverCell = Event.findElement(event, 'td');
            if(hoverCell) {
              var matchResults = /^c(h?)_([0-9]+)(_([0-9]+))?$/.exec(hoverCell.id);
              if(matchResults) {
                var tooltipContents, stateDisplayList;
                stateDisplayList = "";
                tooltipContents = "";
                if(observer.datagrid().chrStateDefs()[matchResults[4]]) {
                  observer.datagrid().chrStateDefs()[matchResults[4]].each(function(state, index) {
                    tooltipContents += index + " : " + state + "<br />";
                    stateDisplayList += "<li>" + index + " : " + state + "</li>";
                  })
                } else {
                  tooltipContents = "NO STATES";
                  stateDisplayList = "<li>NO STATES</li>"
                }
                observer.tooltip().update(tooltipContents)
                if (!observer.datagrid()._quickEditModeOn) $('state_display_list').innerHTML = stateDisplayList;
              } else if(hoverCell.readAttribute('class') == 'mh') {
                observer.tooltip().update('');
              }
            }
          });
        }
      }
    },
    methods: {
      observeForStandardMode: function() {
      },

      observeForQuickEditMode: function() {
        var datagrid = this.datagrid();
        var cellFocus = this.datagrid().cellFocus();
        Event.stopObserving(document, 'keydown');
        Event.observe(document, 'keydown', function(e) {
          var keycode = e.keycode ? e.keycode : e.which;
          // stop viewing window from scrolling without holding key
          if(keycode == Event.KEY_DOWN || keycode == Event.KEY_UP) {
            e.stop()
          }
        });
        Event.stopObserving(document, 'keyup');
        Event.observe(document, 'keyup', function(e) {
          if(Event.element(e).tagName == 'SELECT' || Event.element(e).tagName == 'TEXTAREA' || Event.element(e).type == 'text') {
            return
          }
          var keycode = e.keycode ? e.keycode : e.which;
          var selectedCell = cellFocus.selectedCell();
          if(selectedCell) {
            if(keycode == Event.KEY_RETURN) {
              selectedCell.save();
            } else if(keycode == Event.KEY_ESC) {
              cellFocus.unselectElement();
            // number key pressed
            } else if((keycode >= 48 && keycode < 58) || (keycode >= 96 && keycode < 106)) {
              var keyDigit = keycode >= 96 ? keycode - 96 : keycode - 48;
              selectedCell.toggleState(String(keyDigit));
            // question mark pressed
            } else if(keycode == 63 || keycode == 191) {
              selectedCell.toggleState('?');
            // dash pressed
            } else if(keycode == 109) {
              selectedCell.toggleState('-');
            // directional key pressed
            } else if(keycode >= 37 && keycode < 41) {
              if(keycode == Event.KEY_LEFT) {
                cellFocus.goLeft();
              } else if(keycode == Event.KEY_RIGHT) {
                cellFocus.goRight();
              } else if(keycode == Event.KEY_UP) {
                cellFocus.goUp();
              } else if(keycode == Event.KEY_DOWN) {
                cellFocus.goDown();
              }
              e.stop();
            } else if(keycode >= keyCode('A') && keycode <= keyCode('Z')) {
              if(keycode == keyCode('C')) {
                selectedCell.setStatus('complete');
              } else if (keycode == keyCode('I')) {
                selectedCell.setStatus('incomplete');
              } else if (keycode == keyCode('P')) {
                selectedCell.setStatus('problem');
              }
            //          }
            }
          }
        });
      }
    }
  })
});
