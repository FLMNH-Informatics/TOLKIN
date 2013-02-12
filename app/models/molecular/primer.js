//= require <sync_record>

JooseModule('Molecular', function() {
  JooseClass('Primer', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/molecular/primers/" + this.id();
      }
    },
    classMethods: {
      primers: function () {
        return this._primers;
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
