//= require <sync_record>

Module('Molecular', function() {
  JooseClass('PrimerGene', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/primer_genes/" + this.id();
      }
    },
    classMethods: {
      primers: function () {
        return this._primer_genes;
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
