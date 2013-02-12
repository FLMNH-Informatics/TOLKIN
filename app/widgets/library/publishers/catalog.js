//= require <templates/catalog>
//= require <library/publisher>
//= require "catalogs/action_panel"

JooseModule('Library.Publishers', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      collectionClass: { is: 'ro', init: function () { return Library.Publisher } },
      collectionName: { init: 'library::publisher' },
      columns: { init: function () { return [
            { attribute : "name", width : 500 },
            { attribute : "description", width : 250 },
            { attribute : "creator.label", label : 'Owner', width : 150 },
            { attribute : "created_at", label : 'Created', width : 150 }
      ]}},
          widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Library.Publishers.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
    override: {
      onRowClick: function (event) {
          var pubId = event.element().up('.row').readAttribute('data-id');
          window.location.pathname = "/projects/" + params['project_id'] + "/publishers/" +pubId+'/edit';
        }
    }
  })
});
