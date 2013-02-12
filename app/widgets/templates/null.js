//= require <widget>

JooseModule('Templates', function() {
  JooseClass('Null', {
    isa: Widget,
    methods: {
      renderToString: function () { return '' },
      getFilters: function () { }
    }
  })
});