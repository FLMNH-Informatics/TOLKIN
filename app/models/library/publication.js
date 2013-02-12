//= require <sync_record>

JooseModule('Library', function() {
  JooseClass('Publication', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/publications/" + this.id();
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

