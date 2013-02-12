//= require <sync_record>

Module('Library', function() {
  JooseClass('Citation', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/library/citations/" + this.id();
      }
    },
    classMethods: {
     matrices: function () {
        return this._matrices;
      },
      loadMatrices: function (options) {
        var oldOnSuccess = options.onSuccess;
        options.onSuccess = function (results) {
          this._otus = results;
          if(oldOnSuccess) {
            this.oldOnSuccess(results);
          }
        }
        return this.load(options);
      }
    }
  })
});