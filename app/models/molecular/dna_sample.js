//= require <sync_record>

Module('Molecular', function() {
  JooseClass('DnaSample', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/molecular/dna_samples/" + this.id();
      }
    }
  })
});
