//= require <sync_record>

Module('Molecular', function() {
  JooseClass('PrimerTargetOrganism', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/primer_target_organisms/" + this.id();
      }
    },
    classMethods: {
      primerTargetOrganisms: function () {
        return this._primer_target_organisms;
      },

      loadPrimers: function (options) {
        var oldOnSuccess = options.onSuccess;
        options.onSuccess = function (results) {
          this._primers = results;
          if(oldOnSuccess) {
            this.oldOnSuccess(results);
          }
        }
        return this.load(options);
      }
    }
  })
});
