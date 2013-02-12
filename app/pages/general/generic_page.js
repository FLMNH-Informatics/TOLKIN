//= require <page>

JooseModule('General', function () {
  JooseClass('GenericPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: this.route().pathname
      }, this)}}
    }
  })
})