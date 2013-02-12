//= require <widgets/templates/tooltip>
//= require <widget>
//= require <templates/action_panel>

Module('Molecular.Alignments.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has:{
        collection_view: { is: 'ro', init: function () { return this.parent() } },
        catalog: { is: 'ro', init: function () { return this.parent() } },
        buttons: {
          is: 'ro',
          init: [
            //CREATE NOT USED BECAUSE CREATION SHOULD BE DONE ELSEWHERE (MATRICES/SEQUENCES)
//            { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
            { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' }
          ]
        }
    },
    methods: {
      onClick: function(event) {
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Create':
                this.viewport().widget('window').loadPage('new_project_molecular_alignment_path');
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var alignment = new Molecular.Alignment({context: this.context()});
                  alignment.deleteSelected({collectionString: 'alignment(s)'});
                });
                break;
            }
          }
        }).call(this, event)
      }
    }
  })
});

//      onClick: function(event) {
//        Event.delegate({
//          '#create':function(event){
//                var queue = new Queue();
//                var window = this.viewport().widgets().get('window');
//                queue.join(window.loadPage('new_project_alignment_path', { queue: queue }));
//                queue.add(window.show.bind(window));
//                queue.flush();
//          },
//          '#delete':function(event){
//
//          }
//        }).bind(this)(event);
//      }
//    }
//  })
//});