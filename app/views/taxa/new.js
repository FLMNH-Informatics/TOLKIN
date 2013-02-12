////= require <page>
////= require <taxon>
//
//Module('Views.Taxa', function () {
//  JooseClass('New', {
//    isa: Page,
//    has: {
//      contents: { },
//      records: { is: 'ro', lazy: true, init: function () { return $RSet({
//        taxon: new Taxon({ context: this.frame().context() })
//      }, this)}},
//      collection: { is: 'rw'},
//      title: {
//        is: rw,
//        init: 'New Taxon',
//        nullable: false
//      }
//    },
//    methods: {
//      loadContents: function (options) {
//        var me=this;
//        new Ajax.Request('/projects/' + params['project_id'] + '/taxa/new', {
//          requestHeaders: { Accept: 'text/javascript' },
//          method: 'get',
//          onSuccess: function(transport) {
//            me._contents = transport.responseText;
//            if(options.onSuccess) { options.onSuccess() }
//          }
//        });
//      },
//      renderToString: function () {
//         return this._contents;
//      },
//      onSubmit: function (event) {
//        event.stop();
//        var page = this;
//        event.element().request({
//          onSuccess: function () {
//            page.frame().notifier().success('Taxon created.');
//            page.frame().close();
//            page.records().get('taxon').fire('record:create');
//          },
//          onFailure: function (transport) { page.frame().notifier().error(transport.responseText) }
//        });
//      }
//    }
//  })
//});
