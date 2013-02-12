//= require <sync_record>

Module('Molecular.Matrices.Cells', function() {
  JooseClass('Sequence', {
    isa: SyncRecord,
    methods: {
      destroy: function($super, options) {
        this._afterDestroyCallback = options.callback;
        options.callback = this._notifyUpdateChangeset.bind(this);
        $super(options);
      },

      requestPath: function() {
        return "/projects/" + params['project_id'] + "/molecular/matrices/" + params['matrix_id'] + "/cells/" + params['cell_id'] + "/sequences/" + this.id();
      },

      _notifyUpdateChangeset: function() {
        InternalNotifier.notify('update', 'MatrixChangesetItem');
        if(this._afterDestroyCallback) {
          this._afterDestroyCallback();
        }
      }
    }
  })
});