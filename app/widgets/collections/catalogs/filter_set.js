//= require <widget>
//= require <templates/catalogs/filter_set>

JooseModule('Collections.Catalogs', function() {
  JooseClass('FilterSet', {
    isa: Templates.Catalogs.FilterSet,
    after: {
      setCollectionOptions: function (formHash) {
        this.catalog().collection().finderOptions().order =
          formHash['search[collector_like]'] ?
            ['collection_number'] :
            ['collector', 'collection_number']
      }
    }//,
//    methods: {
//        onSubmit: function(event) {
//          // DONT COMMENT OUT WITHOUT LEAVING A REASON FOR WHY - ChrisG
//          event.stop();
//          var formHash = event.element().serialize({ hash: true, submit: false });
//          var collection =
//          collection.where(true).offset(0)
//
//          $H(formHash).each(function(pair) {
//            var attr_name = pair.key.match(/search\[([\w\.]+)\]/)[1]
//            collection.where(collection.type().attribute(attr_name).eq('%'+pair.value+'%'));
//          });
//          collection.load();
//          //this.catalog().render();
//        }
//      // events
//    }
  })
});
