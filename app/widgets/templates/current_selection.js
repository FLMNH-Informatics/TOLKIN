////= require <widget>
////= require <roles/polling>
//
//Module('Widgets.Templates', function () {
//  JooseClass('CurrentSelection', {
//    isa:  Widget,
//    does: Polling,
//    has: {
//      actionPanel: {init: null}
//    },
//    after: {
//      initialize: function () {
//        this.poll({
//          on: function () { return this.parent().currentSelection() },
//          run: function () { this.parent().currentSelection().addObserver(this, this.handleUpdate) }
//        })
//      }
//    },
//    methods: {
//      onClick: function(event) {
//        Event.delegate({
//          '#cart_deselect_control': function(event) {
//            Effect.BlindUp('shopping_cart_current_selection');
//            this.parent().currentSelection().remove();
//          }
//        }).bind(this)(event);
//      },
//
//      handleUpdate: function(){
//        var selectedItem = this.parent().currentSelection().get();
////        if(eventName == 'destroy') {
////          InternalNotifier.unsubscribe('CurrentSelection', selectedItem._item.klass, selectedItem._item.id);
////          selectedItem._item = null; // remove locally
////          this.removeCurrentSelection(function() {
////            Notifier.success('Selection successfully deleted.');
////          }); // remove on server
////        }else if (eventName == 'update'){
//          if(selectedItem) {
//              if($('shopping_cart_current_selection_name')){
//              $('shopping_cart_current_selection_name').update(selectedItem.label);        }
//            if($('shopping_cart_current_selection')){
//            $('shopping_cart_current_selection').show(); }
//          } else {
//            Effect.BlindUp('shopping_cart_current_selection');
//            if($('shopping_cart_current_selection_name')){
//              $('shopping_cart_current_selection_name').update(''); }
//            }
//
////        }
//      }
//
//
////      _initializeActionPanel: function() {
////        if(this.parent().currentSelection().currentSelection()) { // load action panel and exit
////          this._actionPanel = new TOLKIN.Widget.Taxa.TaxonActionPanel({parent: this.parent()});
////        } else { // recurse ( wait until current selection is loaded )
////          setTimeout(this._initializeActionPanel.bind(this), 100);
////        }
////      }
//    }
//  })
//});
