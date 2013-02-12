//= require <roles/stateful>

JooseClass('HtmlLoader', {
  does: Stateful,
  has: {
    pathname: { is: 'ro', required: true, nullable: false },
    method: { is: 'ro', init: 'get' },
    requestHeaders: { is: 'ro', init: function () { return { Accept: 'text/html' } } },
    paramFunc: { is: 'ro', init: function () { 
      return function () { return { interact_mode: this.iMode() } }
    } },
    page: { is: 'ro', required: true, nullable: false },
    states: { is: 'ro', init: function () { return $States([
      [ 'unloaded', 'loading', 'loaded' ]
    ], this) } }
  },
  methods: {
    state: function () {
      return this.states()
    },
    
    load: function () {
      var me = this
      var page = this.page()
      this.setState('loading')
      new Ajax.Request(Route.forPathname(this.pathname()).buildPath(this.page().params()), {
        method: this.method(),
        requestHeaders: this.requestHeaders(),
        parameters: this.paramFunc().call(this.page()),
        onSuccess: function (transport) {
          page._rendered = transport.responseText
          me.setState('loaded')
          if (page.frame().toString() == "a General.ContentFrame")  $$('.elastic_contents').first().innerHTML =  page._rendered;
        }
      })
    }
  }
})

$HtmlLoader = function (options, page) {
  return new HtmlLoader(Object.extend(options, { page: page }))
}
$HTMLLoader = $HtmlLoader