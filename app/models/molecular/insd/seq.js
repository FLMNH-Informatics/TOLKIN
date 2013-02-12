//= require <sync_record>

JooseModule('Molecular.Insd', function () {
  JooseClass('Seq', {
    isa: SyncRecord,
    classHas: {
      primaryKey: { is: 'ro', init: function () { return new SyncRecords.Attribute( { name: 'pk' } ) } }
    },
    methods: {
      requestPath: function () {
        return "/projects/" + params['project_id'] + "/molecular/sequences/" + this.id();
      }
    }
  });
});