//= require <page>
//= require <otu>
//= require <otus/catalog>

JooseModule('Otus', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//      records: {
//        is: 'ro',
//        lazy: true,
//        init: function () {
//          return $Records({
//            otu:
//
//          }, this)
//        }
//      },
      widgets: {
        is: 'ro',
        lazy: true,
        init: function () {
          return $Widgets({
            otuCatalog:
            new Otus.Catalog({
              parent: this.frame(),
              collection: Otu.collection({ context : this.frame().context() }),
              context: this.frame().context()
            })
          }, this)
        }
      },
      templates: {
        is: 'ro',
        lazy: true,
        init: function () {
          return $Templates([
            'layouts/window',
            'widgets/_catalog',
            'widgets/catalogs/_entry',
            'filters/_form'
//            'otus/catalogs/_action_panel'
            ], this)
        }
      }
    },
    methods: {
      onSubmit: function (event) {
        Event.delegate({
          '#form_add_to_otu_grp': function (event) {
            event.stop()
            new Ajax.Request(event.element().action.toString(), {
              method: 'put',
              parameters: 
              Object.extend(
                event.element().serialize(true),
                {
                  conditions: this.widget('otuCatalog').selected().toString()
                }
                )
            });
          }
        }).bind(this)(event)
      }
    }
  })
});
