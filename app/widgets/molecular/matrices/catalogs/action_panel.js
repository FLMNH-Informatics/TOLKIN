//= require <templates/tooltip>
//= require <widget>
//= require <molecular/matrix>


Module('Molecular.Matrices.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has:{
      catalog: { is: 'ro', init: function () { return this.parent(); } },
      buttons: {
        is: 'ro',
        init: [
          { label: 'Create', img: { src: "/images/small_addnew.gif" }, imode: 'edit' },
          { label: 'Delete', img: { src: "/images/small_cross.png" },  imode: 'edit' }
        ]
      }
    },
    methods: {
      onClick: function(event) {
        var me = this;
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Create':
                this.viewport().widget('window').loadPage('new_project_molecular_matrix_path');
              break;
              case 'Delete':
                this.requireSelection(function(){
                  var matrix = new Molecular.MatrixView({context: this.context()});
                  matrix.deleteSelected({ collectionString: 'matrices' });
                });
              break;
            }
          }
        }).call(this, event)
      }
    }
  })
});
