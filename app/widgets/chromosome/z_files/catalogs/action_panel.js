//= require <templates/action_panel>
//= require <chromosome/z_file>


Module('Chromosome.ZFiles.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    has: {
      buttons: { is: 'ro', init: function () { return [
        { label: 'Upload',   img: { src: '/images/small_addnew.gif' }, imode: 'edit' },
        { label: 'Download', img: { src: '/images/small_arrow.png' },  imode: 'edit' },
        { label: 'Delete',   img: { src: '/images/small_cross.png' },  imode: 'edit' }

      ]}},
      catalog: { is: 'ro', init: function () { return this.parent() }}
    },
    methods: {
      onClick: function(event) {
        var me = this;
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Upload':
                this.viewport().widget('window').loadPage('new_project_chromosome_z_file_path', {
                  probe_id: this.params().id
                })
                break;

                case 'Delete':
                    this.requireSelection(function(){
                        var z_file = new Chromosome.ZFile({context: this.context()});
                        z_file.deleteSelected({collectionString: "ZVI file(s)"});
                    })
                    break;
              case 'Download':
                root.window.location = "/projects/" + params["project_id"] + "/chromosome/z_files/download_z_files?" + "conditions=" + this._parent.selected().toString()
                break;
            }
          }
        }).call(this,event)
      }
    }
  })
});
