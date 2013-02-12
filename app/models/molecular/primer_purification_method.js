//= require <sync_record>

Module('Molecular', function() {
  JooseClass('PrimerPurificationMethod', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/primer_purification_methods/" + this.id();
      }
    },
    classMethods: {
      primerPurificationMethods: function () {
        return this._primer_purification_methods;
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
