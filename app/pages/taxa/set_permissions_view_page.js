//= require <page>

JooseModule('Taxa', function () {
  JooseClass('SetPermissionsViewPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Set Permissions' },
      savable: { is: 'ro', init: true },
      width: { is: 'ro', init: 500 },
      height: { is: 'ro', init: 300 },
      pSetRtid: { is: 'ro', init: null },
      htmlLoader: { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'set_permissions_view_project_taxa_path',
          paramFunc: function () {
            return {
              interactMode: this.iMode(),
              conditions: this.params().conditions,
              permission_set_rtid: this._pSetRtid
            }
          }
        }, this)
      } }//,
//      handlers: { is: 'ro', init: function () { return $Handlers([
//        this.on('state:loading', this.onLoaded.bind(this)),
//        this.on('state:loaded', this.onLoaded.bind(this))
//      ], this) } }
    },
    methods: {
      onClick: function (event) {
        var me = this
        Event.delegate({
          '.saveButton.active': function (event) {
            this.notifier().working('Setting permissions ...')
            $(this.frame().id()).down('form').request({
              onSuccess: function () {
                me.htmlLoader().load()
                me.notifier().success('Permissions set.')
//                me.onLoad()
              }
            })
//            me.state().set('loading')
          }
        }).call(this, event)
      },

      onChange: function (event) {
        Event.delegate({
          'select[name="permissions[permission_set_rtid]"]' : function (event) {
            this._pSetRtid = $F(event.element())
            this.htmlLoader().load()
//            this.onLoad()
//            this.state().set('loading')
          }
        }).bind(this)(event)
      }//,

//      onLoaded: function () {
//        if(this.frame()) {
//          this.frame().render()
//          this.frame().refresh()
//        }
//      },
//
//      onLoad: function () {
//        var me = this;
//        new Ajax.Request(
//          this.route('set_permissions_view_project_taxa_path'), {
//          method: 'get',
//          parameters: {
//            conditions: this.params().conditions,
//            permission_set_rtid: this._pSetRtid
//          },
//          requestHeaders: {
//            Accept: 'text/html'
//          },
//          onComplete: function (transport) {
//            if(transport.status >= 200 && transport.status < 300) {
//              me._rendered = transport.responseText
//            } else {
//              me._rendered = "<font color='red'>"+transport.responseText+"</font>"
//            }
//            me.state().set('loaded')
//
//
//          }
//        });
//      },
//      render: function () {
//        return this._rendered
//      }
    }
  })
})