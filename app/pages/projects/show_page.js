//=require <page>

Module('Projects', function () {
  JooseClass('ShowPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'layouts/window'
        ], this ) }}
    },
    methods: {
      onClick: function (event) {
        if (event.element() == $('edit_project_link')){
          this.frame().viewport().widgets().get('window').loadPage('edit_project_path')
        }
      }
    }
  })
})