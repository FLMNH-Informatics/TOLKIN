//= require <sync_record>

JooseModule('Morphology.Matrices', function() {
  JooseClass('Cell', {
    isa: SyncRecord,
    has: {
      character_id: { is: 'ro' },
      otu_id: { is: 'ro' } },
    after: {
      initialize: function() {
        this._character_id = this.xItemId;
        delete this.xItemId;
        this._otu_id = this.yItemId;
        delete this.yItemId  } },
    methods: {
      requestPath: function() {
        alert('request path being requested');
        var endPath = this.id() || ("new?cell[otu_id]=" + this.otu_id() + "&cell[character_id]=" + this.marker_id());
        return "/projects/" + params['project_id'] + "/morphology/matrices/" + params['matrix_id'] + "/state_codings/" + endPath  } } }) })
