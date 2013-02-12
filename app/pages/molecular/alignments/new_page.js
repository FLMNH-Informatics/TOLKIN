//= require <page>

JooseModule('Molecular.Alignments', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      savable: { is: 'ro', init: true },
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Alignment : New' },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'molecular/alignments/new'
      ], this) } },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_molecular_alignment_path'
      }, this) }}
    },
    methods: {
      onSubmit: function (event) {
        var page = this;
        $(page.frame().id()).down('.status_area').update('creating ...');
      },
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            me.notifier().working('Creating Alignment ...');
            $(me.frame().id()).down('form').request({
              requestHeaders: { Accept: 'application/json' },
              onSuccess: function (transport) {
                me.notifier().success('Alignment Created.');
                me._frame._parent._designatedFrame._page._widgets._initial.catalog._collection.load();
                me.frame().close();
              }
            })
          }//,
        }).call(this, event)
      }//,
    }
  })
});
