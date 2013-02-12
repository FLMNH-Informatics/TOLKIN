//= require <widget>
//= require <templates/action_panel>


JooseModule('Molecular.Primers.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has: {
      catalog: { is: 'ro', init: function () { return this.parent() } },
      buttons: { is: 'ro', init: [
        { label: 'New', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
        { label: 'Delete', img: { src: "/images/small_cross.png" }, imode: 'edit' }
      ]}
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'New':
                this.viewport().widget('window').loadPage('new_project_molecular_primer_path')
                break;
              case 'Delete':
                this.requireSelection(function(){
                  var primer = new Molecular.Primer({context: this.context()});
                  primer.deleteSelected({collectionString: "primer(s)"});
                });
                break;
            }
          }
        }).call(this, event)
      }
    }
  })
})
