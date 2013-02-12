//= require <sync_record>
//= require <route>

JooseClass('Collection', {
  isa: SyncRecord,
  classHas: {
    memberRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_collection_path') }},
    collectionRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_collections_path') }}
  },
  methods: {
    requestPath: function() {
      return "/projects/" + params['project_id'] + "/collections/" + this.id();
    }
  },
  classMethods: {
    collections: function () {
      return this._collections;
    },

    loadCollections: function (options) {
      var oldOnSuccess = options.onSuccess;
      options.onSuccess = function (results) {
        this._collections = results;
        if(oldOnSuccess) {
          this.oldOnSuccess(results);
        }
      }
      return this.load(options);
    }
  }
});

