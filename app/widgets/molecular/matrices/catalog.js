//= require <templates/catalog>
//= require <molecular/matrix_view>
//= require <molecular/matrices/catalogs/action_panel>

JooseModule('Molecular.Matrices', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      collectionName: { init: 'molecular::matrix_view' },
      limit: { is: 'rw', init: 200, nullable: false },
      collectionClass: { init: function () { return Molecular.MatrixView }},
      collection: { is: 'ro', required: true, nullable: false },
      dataId:  { is: 'ro', init: 'id' },
      columns: { init: function () { return [
        { attribute: "name",                              width: 250 },
        { attribute: "description",                       width: 150 },
        { attribute: "copied_from",                       width: 150 },
        { attribute: "created_by",                        width: 90 },
        { attribute: "created_at",                        width: 150 },
        { attribute: "updated_by", label: 'Last Updater', width: 90 },
        { attribute: "updated_at", label: 'Last Update',  width: 150 } ] }},
     widgets: { is: 'ro', init: function () {
         return $Reg({
        actionPanel: new Molecular.Matrices.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } } } ,
    override: {
      onRowClick: function (event) {
        var matVersion = event.element().up('.row').readAttribute('data-id');
        window.location = "/projects/" + params['project_id'] + "/molecular/matrices/" + matVersion;
      }
    }
  })
});
