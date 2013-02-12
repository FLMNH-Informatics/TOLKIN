//= require <page>
//= require <collection>
//= require <collections/taxon_combo_box>

JooseModule('Collections', function () {
  JooseClass('CreateCopyPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'New Collection' },
      savable: { is: 'ro', init: true },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        taxonComboBox: new Collections.TaxonComboBox({
          parent: this.frame(),
          object: new Collection({ context: this.context() })
         }
       )
      }, this) } },
      htmlLoader: { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'create_copy_project_collections_path',
          method: 'put',
          paramFunc: function () {
            return {id : params['collection_id']}
          }
        }, this)
      } }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            me.notifier().working('Creating collection ...');
            $(me.frame().id()).down('form').request({
              onSuccess: function () {
                me.notifier().success('Collection successfully created.');
                (new Collection({ context: me.context() })).fire('create');
                me.frame().back();
              }
            });
          }
        })(event);
      }//,

//      onLoad: function () {
//        var me=this;
//         me.notifier().working('Copying collection to New Window ...');
//         var coll_params = {id : params['collection_id']};
//        new Ajax.Request('/projects/' + params['project_id'] + '/collections/create_copy', {
//          requestHeaders: { Accept: 'text/javascript' },
//          method: 'put',
//          parameters: coll_params,
//          onSuccess: function(transport) {
//            me._contents = transport.responseText;
//            me.notifier().success('New Collection Window loaded successfully.');
//            //me.frame().render();
//            //me.frame().refresh();
//            me.state().set('loaded');
//            //if(options.onSuccess) { options.onSuccess() }
//          }
//        });
//      },
////       loadContents: function (options) {
////
////       },
//       render : function () {
//          return this._contents;
//       }
//    }

//      forms: { is: 'ro', init: function() { return new FormSet({
//           newForm: new Form({})
//      }, this ) }
    }
  })
});
