//= require <widget>

Module('Taxa', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    after: {
      initialize: function () {
        var userPanel = this;
        //this.actionList = new TaxaActionList('user_panel_action_list');
        // when window scrolls keep action panel and instructions in view
        if(params['action'] == 'tree_view') {
          Event.observe('contents', 'scroll', function(event) {
            userPanel._scrollInstructions()
          });
        }
      }
    },
    methods: {
    _scrollElement: function(id, initialOffset) {
      var topInViewport = $('contents').viewportOffset().top;
      var topInDocument = $('contents').cumulativeOffset().top;
      var neededOffset = initialOffset + (topInDocument - topInViewport)

      $(id).setStyle('top: ' + neededOffset + 'px');
    },

    _scrollInstructions: function() {
      this._scrollElement('tree_browse_instructions', 5);
    }
  }
  })
});
