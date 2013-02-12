//= require <sync_record>

JooseModule('Molecular.Matrices', function() {
  JooseClass('Cell', {
    isa: SyncRecord,

//    after: {
//      initialize: function() {
//        this.marker_id = this.xItemId;
//        delete this.xItemId;
//        this.otu_id = this.yItemId;
//        delete this.yItemId;
//      }
//    },
    methods: {
      loadAttributes: function($super, options) {
        this._origLoadAttributesCallback = options.callback;
        options.callback = function() {
          InternalNotifier.subscribe(this.onPrimarySequenceChange.bind(this), this.klass + "_" + this.id,
            'MolecularMatrixCellSequence', this.primary_sequence_id);
          this._origLoadAttributesCallback();
        }.bind(this);
        $super(options);
      },

      onPrimarySequenceChange: function(eventName) {
        if(eventName == 'destroy') {
          this.primary_sequence_id = null;
          InternalNotifier.notify('update', this.klass, this.id);
        }
      },

      requestPath: function() {
        var endPath = this.id || ("new?cell[otu_id]=" + this.otu_id + "&cell[marker_id]=" + this.marker_id);
        return "/projects/" + params['project_id'] + "/molecular/matrices/" + params['matrix_id'] + "/cells/" + endPath;
      }
    }
  })
});

