//= require <sync_record>

Module('Molecular', function() {
  JooseClass('Alignment', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/molecular/alignments/" + this.id();
      }
    },
    classMethods: {
      alignments: function () {
        return this._alignments;
      },

      get: function (id) {
        if(!this._cached) { this._cached = {} }
        return this._cached[id];
      },

      loadAlignments: function (options) {
        var oldOnSuccess = options.onSuccess;
        options.onSuccess = function (results) {
          this._alignments = results;
          if(oldOnSuccess) {
            this.oldOnSuccess(results);
          }
        }
        return this.load(options);
      }
    }
  })
});