//= require <page>
//= require <taxon>

Module('Taxa', function() {
  JooseClass('ListPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
          'taxa/list'
      ], this)}}
    },
    methods: {
      onClick: function (event) {
        var me = this
        Event.delegate({
          '.taxa-link': function (event) {
              event.stop();
              window.open(event.target.href, '_blank');
          }
        }).call(this, event);
      }
    }
  })
})

