//= require <sync_record>

JooseModule('Molecular.Matrices', function () {
  JooseClass('Submatrix', {
    isa: SyncRecord,
//    classHas: {
//      primaryKey: { is: 'ro', init: function () { return new SyncRecords.Attribute( { name: 'pk' } ) } }
//    },
    methods: {
      requestPath: function () {
        return "/projects/" + params['project_id'] + "/molecular/matrices/" + params["matrix_id"] + "/submatrices/" + this.id();
      }
    }
  });
});