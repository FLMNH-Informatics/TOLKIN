//= require <sync_record>
//= require <matrices/version_information>

Module('Morphology', function() {
  JooseClass('Matrix', {
    isa: SyncRecord,
    does: VersionInformation
    //NOTE:  doesn't need method: requestPath because VersionInformation takes care of that
  })
});
