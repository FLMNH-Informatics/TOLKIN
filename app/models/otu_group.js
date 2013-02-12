//= require <sync_record>

JooseClass('OtuGroup', {
  isa: SyncRecord,
  methods: {
    requestPath: function() {
      return "/projects/" + params['project_id'] + "/otu_groups/" + this.id();
    }
  },
  classMethods: {
    otus: function () {
      return this._otu_groups;
    },

    loadOtus: function (options) {
      var oldOnSuccess = options.onSuccess;
      options.onSuccess = function (results) {
        this._otu_groups = results;
        if(oldOnSuccess) {
          this.oldOnSuccess(results);
        }
      }
      return this.load(options);
    }
  }
})