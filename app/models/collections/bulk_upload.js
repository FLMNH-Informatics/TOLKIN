/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 12/7/11
 * Time: 11:27 AM
 * To change this template use File | Settings | File Templates.
 */

//= require <sync_record>
//= require <route>

JooseClass('Collections.BulkUpload', {
  isa: SyncRecord,
  classHas: {
    memberRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_bulk_upload_path') }},
    collectionRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_bulk_uploads_path') }}
  },
  methods: {
    requestPath: function() {
      return "/projects/" + params['project_id'] + "/bulk_uploads/" + this.id();
    }
  }
});