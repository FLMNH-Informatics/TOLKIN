//= require <sync_record>
//= require <route>

Module('Chromosome', function(){
  JooseClass('Dye', {
    isa: SyncRecord,
    classHas: {
      memberRoute: {
        is: 'ro',
        lazy: true,
        init: function () {
          return Route.forPathname('project_chromosome_dye_path')
        }
      },
    collectionRoute: {
      is: 'ro',
      lazy: true,
      init: function () {
        return Route.forPathname('project_chromosome_dyes_path')
      }
    }
  }
})
})
