//= require <templates/catalog>
//= require <library/publication>
//= require "catalogs/action_panel"

JooseModule('Library.Publications', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      collectionClass: { is: 'ro', init: function () { return Library.Publication } },
      collectionName: { init: 'library::publication' },
      columns: { init: function () { return [
            { attribute : "name", width : 500 }//,
//            { attribute : "description", width : 250 },
//            { attribute : "creator.label", label : 'Owner', width : 150 },
//            { attribute : "created_at", label : 'Created', width : 150 }
      ]}},
          widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Library.Publications.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
    override: {
      onRowClick: function (event) {
         Event.delegate({
          "tr['data-id']" : function (event) {
            params['id'] = event.element().up("tr['data-id']").readAttribute('data-id');
            var window = this.viewport().widgets().get('window');
            window.loadPage('project_publication_path', { id: params['id'] })
          }
        }).bind(this)(event);
        this.SUPER(event);
      }
    }
  })
});
