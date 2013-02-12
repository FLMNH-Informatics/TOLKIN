//= require <sync_record>

JooseModule('Ncbi', function () {
  JooseClass('Seq', {
    isa: SyncRecord
  });
});