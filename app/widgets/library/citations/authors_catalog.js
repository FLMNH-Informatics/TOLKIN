//= require <templates/catalog>
//= require <templates/null>
//= require <library/citations/authors_catalog_action_panel>
//= require <simple_selected>

JooseModule('Library.Citations', function () {
  JooseClass('AuthorsCatalog', {
    isa: Templates.Catalog,
    has: {
      authors: { is: 'ro', required: true, nullable: false },
      collection: { is: 'ro', init: function () { return this.authors() } },
      columns: { is: 'ro', init: function () { return [
        { attribute: 'name', label: 'Author', width: 300 },
        { moveControls: true, label: '', width: 100 }
      ]
      } },
      limit: { is: 'ro', init: null },
      hasContentsForm: { is: 'ro', init: false },
      hasFilterSet: { is: 'ro', init: false },
      selected: { is: 'ro',
        lazy: true, // lazy required, this.collection() does not exist yet
        init: function () { return new SimpleSelected({ catalog: this }) }
      },
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Library.Citations.AuthorsCatalogActionPanel({ parent: this }),
        filterSet:   new Templates.Null({ parent: this })
      }, this) } }
    }
  });
});
