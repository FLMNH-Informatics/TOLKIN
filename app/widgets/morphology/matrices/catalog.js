//= require <templates/catalog>
//= require <morphology/matrix_view>
//= require <morphology/matrices/catalogs/action_panel>

JooseModule('Morphology.Matrices', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      collectionName: { init: 'morphology::matrix_view' },
      limit: { is: 'rw', init: 200, nullable: false },
      collectionClass: { init: function () { return Morphology.MatrixView }},
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
        actionPanel: new Morphology.Matrices.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } } } ,
    override: {
      onRowClick: function (event) {
        var matVersion = event.element().up('.row').readAttribute('data-id');
        window.location = "/projects/" + params['project_id'] + "/morphology/matrices/" + matVersion;
      }
    }
  })
});




////= require <templates/catalog>
////= require <matrices/branch>
////= require "catalogs/action_panel"
//
////overwrites the limit field for matrices unlike other catalogs, this was a requirement
//JooseModule('Morphology.Matrices', function () {
//  JooseClass('Catalog', {
//    isa: Templates.Catalog,
//    has: {
////      collectionClass: { is: 'ro', init: function () { return Models.Matrices.Branch } },
//      limit: { is: 'rw', init: 20, nullable: false },
////      collectionName: { init: 'matrix::branch' },
//      dataId: { is: 'ro', init: 'matrix_id' },
//      columns: { init: function () { return [
//        { attribute : "name",                                  width : 250 },
//        { attribute : "description",                           width : 150 },
//        { attribute : "parent.branch.name",   label : 'submatrix of', width : 250 },
//        { attribute : "updater_name", label : 'Last Updator', width : 100 },
//        { attribute : "updated_at",    label : 'Last Update',  width : 150, type: 'date' },
//        { attribute : "creator.user.full_name", label : 'Owner',        width : 100 },
//        { attribute : "created_at",    label : 'Created',      width : 150, type: 'date' }
//      ] }},
//      collection: { is: 'ro', init: function () { return(
//        Morphology.Matrix.collection({ context: this.context() })
//          .limit(20)
////          .select('name',
////                  'description',
////                  'parent_name',
////                  'creator_name',
////                  'updater_name',
////                  'created_at',
////                  'updated_at')
////          .order('branches.created_at desc')
//      )}},
//          widgets: { is: 'ro', init: function () {
//              return $Reg({
//        actionPanel: new Morphology.Matrices.Catalogs.ActionPanel({parent: this}),
//        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
//      }, this) } }
//    },
//    override: {
//      onRowClick: function (event) {
//          var matrixId = event.element().up('.row').readAttribute('data-id');
//          window.location.pathname = this.context().routes().pathFor('project_morphology_matrix_path', { id: matrixId });
//        }
//    }
//  })
//});
