//= require <sync_record>
//= require <matrices/version_information>

Module('Molecular', function() {
  JooseClass('Matrix', {
    isa: SyncRecord,
    does: VersionInformation,
    methods: {
      requestPath: function () {
        return "/projects/" + params['project_id'] + "/molecular/matrices/" + this.id();
      }
    }
  })
});
