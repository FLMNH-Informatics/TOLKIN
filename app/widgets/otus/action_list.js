////= require <models/otu>
////= require <widget>
//
//Module('Otus', function () {
//  JooseClass('ActionList', {
//    isa: Widget,
//    has: {
//      context: { is: 'ro', required: true, nullable: false}
//    },
//    methods: {
//      onClick: function(event) {
//        Event.delegate({
//          '#delete_from_cart': function(event) {
//
//            var item_type ={
//              type: "Otu"
//            };
//            var catalog_obj = this.parent().top().widgets().get('contentFrame').widgets().get('viewport_content_frame_otus_catalog');
//            Models.Otu.destroy(item_type, this.context(),catalog_obj);
//
//
//          },
//          'new_otu': function(event) {
//
//          },
//          'add_cart_to_otu_group':function(event) {
//
//          }
//
//          }).bind(this)(event);
//      }
//    }
//  })
//});
