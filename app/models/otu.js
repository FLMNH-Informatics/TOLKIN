//= require <sync_record>
JooseClass('Otu', {
  isa: SyncRecord,
  methods: {
    requestPath: function() {
      return "/projects/" + params['project_id'] + "/otus/" + this.id();
    }
  },
  classMethods: {
    otus: function () {
      return this._otus;
    },

    loadOtus: function (options) {
      var oldOnSuccess = options.onSuccess;
      options.onSuccess = function (results) {
        this._otus = results;
        if(oldOnSuccess) {
          this.oldOnSuccess(results);
        }
      }
      return this.load(options);
    },
    destroy:function(item_type, context,catalog_obj){
      context.notifier().working('Deleting Selected items from Cart ...');
      new Ajax.Request("/projects/" + params['project_id'] + "/otus/delete_selected", {
        method: 'post',
        parameters:item_type ,
        onSuccess: function(transport) {
          context.globalCart().removeForType(item_type.type);
          catalog_obj.collection().load();
          context.notifier().success('OTUs successfully deleted');
        },
        onFailure: function(){
          context.notifier().error('problem deleting current selection');
        }
      });
    }
  }
})