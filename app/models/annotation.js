//= require <sync_record>
//= require <route>

JooseClass('Annotation', {
  isa: SyncRecord,
  classHas: {
    memberRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_collection_annotation_path') }},
    collectionRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_collection_annotations_path') }}
  },
//  methods: {
////    requestPath: function() { DEPRECATED
////      return "/projects/" + params['project_id'] + "/collections/" + this.id() + "/annotations";
////    }
//  },
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

