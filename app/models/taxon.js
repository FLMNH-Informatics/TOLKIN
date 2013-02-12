//= require <sync_record>
//= require <sync_records/attribute>

JooseClass('Taxon', {
  isa: SyncRecord,
  classHas: {
    primaryKey: { is: 'ro', init: function () { return new SyncRecords.Attribute({ name: 'taxon_id' }) } }
  },
  methods: {
    loadChildren: function(options) {
      var taxon = this;
      new Ajax.Request(Route.forPathname('project_taxa_path').getInterpolatedPath(params), {
        requestHeaders: {
          Accept: 'application/json'
        },
        method: 'get',
        parameters: {
          'select[]': ['taxon_id', 'name', 'has_children', 'namestatus_id'],
          'include[namestatus][select][]': [ 'id', 'status' ],
          'conditions': this.id()+'[parent_taxon_id]'
        },
        onSuccess: function(transport) {
          taxon.children = transport.responseJSON.taxa.collect(function(entry) {
            return entry.taxon;
          })
          if(options.callback) {
            options.callback();
          }
        },
        onFailure: function() {
          Notifier.error('Could not retrieve taxon children.');
        }
      })
    },

    requestPath: function() {
      return "/projects/" + params['project_id'] + "/taxa/" + this.id();
    }
  },
  override: {
    _processLoad: function(object) {
      //object.namestatus = object.namestatus || { };
      if (object.namestatus && object.namestatus.status) {
        object.namestatus.status = object.namestatus.status.gsub(/_/, ' ')
      }
      object.created_at = Date.format(object.created_at);
      object.updated_at = Date.format(object.updated_at);
      //object.collections_count = object.collections.size();
      //object.collections = object.collections.slice(0, 20);
      return this.SUPER(object);
    }
  }
});


