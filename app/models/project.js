//= require <sync_model>

Module('Models', function() {
  JooseClass('Project', {
    isa: SyncModel,
    methods: {
      loadCollections: function(options) {
        this._loadHasManyRelation('collections', Object.extend(options, {
          only: 'id,collector,collection_number,label,country,taxon_id',
          include: 'taxon',
          callback: options.callback
        }));
      },

      requestPath: function() {
        return "/projects/" + params['project_id']
      }
    }
  })
});

