//= require <sync_record>

Module('Morphology', function() {
  JooseClass('MatrixView', {
    isa: SyncRecord,
    classHas: {
      memberRoute: { is: 'ro', lazy: true, init: function () {
        return Route.forPathname('project_morphology_matrix_path');
      }},
      collectionRoute: { is: 'ro', lazy: true, init: function () {
        return Route.forPathname('project_morphology_matrices_path');
      }}
    },
    methods: {
      requestPath: function () {
        return "/projects/" + params['project_id'] + "/morphology/matrices/" + this.id();
      }
    }
  })
});
