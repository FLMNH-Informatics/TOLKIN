//= require <page>

Module('General', function() {
  JooseClass('BlankPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false }
      
    }
  })
})


