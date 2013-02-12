//= require <templates/catalog>
//= require <templates/null>
//= require <collections/annotations_catalog_action_panel>
//= require <simple_selected>

JooseModule('Collections', function () {
  JooseClass('AnnotationsCatalog', {
    isa: Templates.Catalog,
    has: {
      annotations: { is: 'ro', required: true, nullable: false },
      collection: { is: 'ro', init: function () { return this.annotations() } },
      columns: { is: 'ro', init: function () { return [
        { attribute: 'taxon', label: 'Taxon', width: 182 },
        { attribute: 'name', label: 'Determiner', width: 150},
        { attribute: 'date', label: 'Date', width: 100},
        { attribute: 'inst', label: 'Institution', width: 150}
      ] } },
      limit: { is: 'ro', init: null },
      anObj: { is: 'rw', init: function () { return { remove_ids: $A([]), add: $H({}) } } },// ATTN: Greg - init here needs function () {} wrapper, else all collections show pages, past and present, will share same contents. Sincerely, Chris
      hasContentsForm: { is: 'ro', init: false },
      hasFilterSet: { is: 'ro', init: false },
      selected: { is: 'ro', init: function () { return new SimpleSelected({ catalog: this }) } },
      widgets: { is: 'ro', init: function () { return $Widgets({
        actionPanel: new Collections.AnnotationsCatalogActionPanel({ parent: this }),
        filterSet: new Templates.Null({ parent: this })
      }, this) } }
    }
  })
})
