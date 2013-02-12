//= require <page>
////= require <publication>
////= require <livevalidation>

JooseModule('Views.Library.Publications', function () {
  JooseClass('New', {
    isa: Page,
    has: {
      title: { is: 'ro', init: 'New Publication' }
    },
    methods: {
      onLoad: function () {
        var me=this;
        new Ajax.Request('/projects/' + params['project_id'] + '/publications/new', {
          requestHeaders: { Accept: 'text/javascript' },
          method: 'get',
          onSuccess: function(transport) {
            me._contents = transport.responseText;
            //me.frame().render();
            //me.frame().refresh();
            me.state().set('loaded');
            //if(options.onSuccess) { options.onSuccess() }
          }
        });
      },
//       loadContents: function (options) {
//
//       },
       renderToString : function () {
          return this._contents;
       }
    }

//      forms: { is: 'ro', init: function() { return new FormSet({
//           newForm: new Form({})
//      }, this ) } }

  })
});
