//= require <templates/catalog>
//= require <library/citation>
//= require "catalogs/action_panel"

JooseModule('Library.Citations', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,   
    has: {
      collectionClass: { is: 'ro', init: function () { return Library.Citation } },
      collectionName: { init: 'library::citation' },
      columns: { init: function () { return [
        { attribute : "authors_joined", label: 'Authors', width: 200 },
        { attribute : "year",   width : 50 },
        { attribute : "title",  width : 350 },
        { attribute : "publication.publication.value", label: 'Publication', width : 150 }
          ] }},
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Library.Citations.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
    override: {
      onRowClick: function (event) {
        var id = event.element().up('.row').readAttribute('data-id');
        this.viewport().widget('window').loadPage('project_library_citation_path', { id: id });
        //cit_det(citId, params['project_id']);
      }
    } 
  })
});
