//= require <sync_record>

JooseModule('Molecular', function () {
  JooseClass('Marker', {
    isa: SyncRecord,
    classHas: {
      memberRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname(
        'project_molecular_marker_path'
      ) } },
      collectionRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname(
        'project_molecular_markers_path'
      ) } }
    }
  })
})
