//= require <templates/action_panel>
//= require <chromosome/probe>

Module('Chromosome.Probes.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has: {
      buttons: {
        is: 'ro',
        init: function () {
          return [

          {
            label: 'Create',
            img: {
              src: '/images/small_addnew.gif'
            },
            imode: 'edit'
          },
          {
            label: 'Delete',
            img: {
              src: '/images/small_cross.png'
            },
            imode: 'edit'
          }
          ]
        }
      },
      catalog: {
        is: 'ro',
        init: function () {
          return this.parent()
        }
      }
    },
    methods: {

      onClick: function(event) {
        var me = this;
        Event.delegate({
          'input[type="button"]': function (event) {

          switch (event.element().readAttribute('value')) {
        

            case 'Create':
              this.viewport().widget('window').loadPage('new_project_chromosome_probe_path', {
                probe_id: this.params().id
              })
              break;
              
            case 'Delete':
              this.requireSelection(function(){
                var probe = new Chromosome.Probe({context: this.context()});
                probe.deleteSelected({collectionString: "probe(s)"});
              })
              break;
          }
        }
      }).call(this,event)
    }
    }
  })
});
