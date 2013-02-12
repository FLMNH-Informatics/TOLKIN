Module('TOLJS.role', function() {
  Role('Tabbed', {
    has: {
      tabs: { is: 'ro', required: true },
      currentTab: { is: 'rw', init: 'general' },
      transitionTabsAndContentQueue: { is: 'ro', init: function () { return [] } },
      transitionTabsAndContentRunning: { is: 'ro', init: false }
    },
    before: {
      show: function () {
        $(this.id()).down("#" + this.currentTab() + "_section").show();
      }
    },
    override: {
      onClick: function (event) {
        Event.delegate({
          '.tab.active': function(event) {
            var element = event.element().hasClassName('tab') ? event.element() : event.element().up('.tab');
            this.setCurrentTab(element.id.match(/(\w+)_tab/)[1]);
  //          this._beforeTransitionTabsAndContent(event);
            this._transitionTabsAndContent(event.element());
          }
        }).bind(this)(event);
        this.SUPER(event);
      },
      
      render: function (options) {
        options = options || {};
        options.windowTemplate = options.windowTemplate || this.parent().templates().get('layouts/window');
        options.windowTemplate = (options.windowTemplate.fill({
          tab_bar: this._tabBar()
        }));
        this.SUPER(options);
        if(this.currentTab()) {
          $(this.currentTab() + '_section').show();
        }
        return this;
      }
    },
    methods: {
      _tabBar: function () {
        var tabs = "<ul class='tab_bar'>";
        this.tabs().each(function(tab) {
          var tabClass = (this.currentTab() == tab) ? 'tab active selected' : 'tab active';
          tabs += "<li id='" + tab + "_tab' class='" + tabClass + "'>" + tab + "</li>";
        }.bind(this))
        tabs += "</ul>";
        return tabs;
      },

//      _beforeTransitionTabsAndContent: function () { },
//      _afterTransitionTabsAndContent: function () { },

      // transitions will be run one after another.  if a transition called before another is finished, it
      // will be queued up to run afterwards
      _transitionTabsAndContent: function(clickedLink, options) {
        options = options || {};
        var box = this;
        function runTransition () {
          // get old and new tab names
          var oldSelectedName = $(box.id()).down('.tab.selected').id.match(/^(\w+)_tab$/)[1];
          var clickedTab = (clickedLink.hasClassName('tab') ? clickedLink : clickedLink.up('.tab'));
          var newSelectedName = clickedTab.id.match(/^(\w+)_tab$/)[1];

          // unselect old tab
          $(oldSelectedName + '_tab').removeClassName('selected');

          // get dimensions of old content box
          var oldWidth = $(oldSelectedName + '_section').getStyle('width')
          var oldHeight = $(oldSelectedName + '_section').getStyle('height');

          // hide old content and bring new content up just to measure dimensions, then hide again
          $(oldSelectedName + '_section').removeClassName('selected');
          $(newSelectedName + '_section').addClassName('selected');
          var newWidth = $(newSelectedName + '_section').getStyle('width')
          var newHeight = $(newSelectedName + '_section').getStyle('height');
          $(newSelectedName + '_section').removeClassName('selected');

          // select new tab
          $(newSelectedName + '_tab').addClassName('selected');

          // insert transition box
          $(box.id()).down('ul').insert({
            after: "<div id='tabbed_box_transitional_section' class='body selected' style='width: " + oldWidth + "; height: " + oldHeight + "'></div>"
          });
          var tabbedBox = box;
          // morph transition box from old to new
          $('tabbed_box_transitional_section').morph("width: " + newWidth + "; height: " + newHeight + ";", {
            duration: 0.5,
            afterFinish: function() {
              // after morph complete replace transition box with new content box
              $('tabbed_box_transitional_section').remove();
              $(newSelectedName + '_section').addClassName('selected');
              if(options.afterFinish) {
                options.afterFinish();
              }
              // run next transition in lineup if there is one
              if(box._transitionTabsAndContentQueue.size() > 0) {
                box._transitionTabsAndContentQueue.pop()();
              } else {
                box._transitionTabsAndContentRunning = false;
              }
            }
          });
        }

        if(!this._transitionTabsAndContentRunning) {
          this._transitionTabsAndContentRunning = true;
          runTransition();
        } else {
          this._transitionTabsAndContentQueue.push(runTransition.bind(this));
        }
      }
    }
  })
});


