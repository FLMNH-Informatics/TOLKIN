//= require <widgets/templates/action_panel>

Module('Widgets.Molecular.Bioentries.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Widgets.Templates.ActionPanel,
    has: {
      buttons: { is: 'ro', init: function () { return [
          { label: 'Import', img: { src: '/images/addnew.gif' } }, 
          { label: 'Delete Selected', img: { src: '/images/addnew.gif' } }
      ] } },
      catalog: { is: 'ro', init: function () { return this.parent() } }
    },
    methods: {
      onClick: function(event) {
        var button = event.element().hasClassName('button') ?  event.element() : event.element().up('.button');
        if(button) {
          switch(button.down('.label').innerHTML) {
            case 'Import':
              var window = this.viewport().widgets().get('window');
              window.loadPage('bioentries_path');
              window.show();
              break;
            case 'Delete Selected':
//                var item_type ={
//                  type: "Bioentry"
//                };
               // var catalog_obj = this.parent().top().widgets().get('contentFrame').widgets().get('viewport_content_frame_molecular_bioentries_catalog');

                this._parent.selected().destroy(this.context());
                //Molecular.Bioentry.destroy(this.catalog().selected(), this.context());
                break;
            case 'Align':
            
              var val = this.catalog().selected()._ids.size();
              var me = this;
              if(val < 1){
                alert('Must select two or more sequences');
              }else{
                var window = this.viewport().widgets().get('window');
                this.context().params().selected = this.catalog().selected();
                window.loadPage('new_alignment_project_bioentries_path');
                /*new Ajax.Request(context.routes().pathFor('align_project_bioentries_path'), {
                  parameters: { conditions: this.toString() }
                })*/
              }
              //this._parent.selected().align(this.context());
              break;
          }
        }
      }
    }
  })
});
