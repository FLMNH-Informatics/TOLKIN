//= require <sync_record>
//= require <route>

JooseModule('', function () {
Module('Chromosome', function(){
  JooseClass('ZFile', {
    isa: SyncRecord,
    classHas: {
      //route: { is: 'ro', init: function () { return Route.forPathname('project_chromosome_z_file_path') }},
      memberRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_chromosome_z_file_path') }},
      collectionRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_chromosome_z_files_path') }}
    },
    methods: {
        requestPath: function (){
        return "/projects/" + params['project_id'] + "/chromosome/z_files/" + this.id();
      }
    }
  })
})
});

//JooseModule('Chromosome', function () {
//  JooseClass('ZFile', {
//    isa: SyncRecord
//  })
//});

