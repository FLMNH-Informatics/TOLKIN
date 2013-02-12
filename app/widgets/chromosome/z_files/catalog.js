//= require <templates/catalog>
//= require <templates/catalogs/filter_set>
//= require <chromosome/z_file>
//= require "catalogs/action_panel"

Module('Chromosome.ZFiles', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      dataId: { is: 'ro', init: 'id' },
      columns: { init: function () { return [ 
            { attribute: "zvi_file_name", label: "ZVI filename", width: 200 },
            { attribute: "caption", width: 230 }
          ] }},
      width: { init: 500},
      showFiller: { is: 'ro', init: false},
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Chromosome.ZFiles.Catalogs.ActionPanel({ parent: this }),
        filterSet:   new Templates.Catalogs.FilterSet({ parent: this, catalog: this })
      }, this ) } }

    },
    override: {
      onRowClick: function (event) {
        var z_fileId = event.element().up('.row').readAttribute('data-id');
    
        //this.viewport().widget('window').loadPage('project_chromosome_z_file_path', { id: z_fileId })
        window.location = this.route('project_chromosome_z_file_path', { id: z_fileId })
      }
    }
  })
});
