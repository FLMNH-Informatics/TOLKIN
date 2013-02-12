//= require <sync_record>

Module('Morphology', function() {
  JooseClass('ChrGroup', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/morphology/chr_groups/" + this.id();
      }
    },
    classMethods: {
      characters: function () {
        return this._characters;
      },

      loadCharacters: function (options) {
        var oldOnSuccess = options.onSuccess;
        options.onSuccess = function (results) {
          this._characters = results;
          if(oldOnSuccess) {
            this.oldOnSuccess(results);
          }
        }
        return this.load(options);
      }
    }
  })
});


