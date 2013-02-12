//= require <sync_record>
//= require <route>

Module('Chromosome', function(){
  JooseClass('Probe', {
    isa: SyncRecord,
    classHas: {
      memberRoute:     { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_chromosome_probe_path')  }},
      collectionRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_chromosome_probes_path') }}
    },
    methods: {
      requestPath: function (){
        return "/projects/" + params['project_id'] + "/chromosome/probes/" + this.id();
      }
    }
  })
})