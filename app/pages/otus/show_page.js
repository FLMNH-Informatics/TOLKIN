//= require <page>

JooseModule('Otus', function () {
  JooseClass('ShowPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      records: { is: 'ro', init: function () { return $Records({
        otu: new Otu({ id: this.params().id, context: this.context() })
      }, this) }}
    },
    methods: {
      onClick: function (event) {
        var innerText = event.element().innerHTML
        var iMode = this._context._interactMode
        if (innerText == 'Add Taxon to Otu'){
          if (iMode == 'edit'){
            event.stop()
            this.frame().viewport().widget('window').loadPage('show_add_taxon_project_otu_path')
          }
          else if (iMode == 'browse'){
            alert('You must be in edit mode to complete this action')
          }
        }
      }
    }
  })
})