//= require <sync_record>

Module('Molecular', function() {
  JooseClass('MatrixView', {
    isa: SyncRecord,
    classHas: {
      memberRoute: { is: 'ro', lazy: true, init: function () {
        return Route.forPathname('project_molecular_matrix_path');
      }},
      collectionRoute: { is: 'ro', lazy: true, init: function () {
        return Route.forPathname('project_molecular_matrices_path');
      }}
    },
    methods: {
      requestPath: function () {
        return "/projects/" + params['project_id'] + "/molecular/matrices/" + this.id();
      }
    }
  })
});
