//= require <sync_record>

Module('Morphology', function() {
  JooseClass('Character', {
    isa: SyncRecord,
    methods: {
      requestPath: function() {
        return "/projects/" + params['project_id'] + "/morphology/characters/" + this.id();
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


