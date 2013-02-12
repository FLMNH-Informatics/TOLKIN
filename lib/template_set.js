//= require <roles/stateful>

JooseClass('TemplateSet', {
  does: Stateful,
  has: {
    initial: { },
    owner: { is: 'ro', required: true, nullable: false },
    templates: { init: function () { return [] }},
    states: { is: 'ro', init: function () { return new State([
      [ 'notLoaded', 'loading', 'loaded' ]
    ], this)}}
//    loaded: { is: 'ro', init: false }
  },
  after: {
    initialize: function () {
      this.state().set('notLoaded');
      this._templates.push(this._initial)
      this._templates = this._templates.flatten()
    }
  },
  methods: {
    
    state: function () {
      return this.states()
       },
//    handleEvent: function (event) {
//      switch(event.type()) {
//        case 'loaded':
//          this._loaded = true;
//          this.fire('templates:loaded');
//      }
//    },

    load: function (options) {
      this.state().set('loading');
      var me = this;
      options || (options = {});
      if(!options.onto) { throw('onto required') }
      options.onto.load(this._templates);
      options.onto.on('state:loaded', function () { 
        me.state().set('loaded');
      });
      return true;
    }
  }
})

$TSet = function (array, owner) {
  return new TemplateSet({ initial: array, owner: owner })
}
$Templates = $TSet;


