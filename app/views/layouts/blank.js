//= require <page>

Module('Views.Layouts', function() {
  JooseClass('Blank', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false }
    }
  })
});


