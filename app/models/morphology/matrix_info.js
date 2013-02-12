//= require <sync_record>

Module('Morphology', function() {
  JooseClass('MatrixInfo', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params["project_id"] + "/morphology/matrices/" + this.id()
      }
    },
    classMethods: {
      is_last_version: function () {

      }
    }
  })
});
