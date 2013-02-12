//= require <templates/catalog>
//= require <otu_group>
//= require "catalogs/action_panel"

JooseModule('OtuGroups', function () {
  JooseClass('Catalog', {
    isa:  Templates.Catalog,
    has: {
      collectionClass: { is: 'ro', init: function () { return OtuGroup } },
      collectionName: { init: 'otu_group' },
      columns: { init: function () { return [
            { attribute: "name", width: 250 },
            { attribute: "creator.user.full_name", label: "Owner",width: 150 }
          ] }},
          widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new OtuGroups.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
    override: {
      onRowClick: function (event) {
          var otuId = event.element().up('.row').readAttribute('data-id');
          window.location.pathname = this.context().routes().pathFor('project_otu_group_path', { id: otuId });
          //TODO: not used because OTU list wasn't working
          //if you fix it, comment out the line above, and rename the show page
          //this.viewport().widget('window').loadPage('project_otu_group_path', { id: otuId })
        }
    }//,
//    augment:{
//      onChange: function (event) {
//        Event.delegate({
//          "input[type='checkbox']" : function (event) {
//            //Implement Otu Groups here
//            if($F(event.element())){
//              //this.parent().globalCart().add('Otu', event.element().up('.sortable').getAttribute("data-id"), event.element().up(0).next(0).innerHTML);
//            } else {
//              //this.parent().globalCart().remove('Otu', event.element().up('.sortable').getAttribute("data-id"));
//              //this.selected().remove(dataId);
//            }
//          }
//        }).bind(this)(event);
//      }
//    }
//    ,
//    methods: {
//      onClick: function (event) {
//        if(!(event.element().readAttribute('type') == 'checkbox') && !event.element().down("type['checkbox']") &&  event.element().up('.row')) {
//          var otuId = event.element().up('.row').readAttribute('data-id');
//          window.location.pathname = "/projects/" + params['project_id'] + "/otu_groups/" + otuId;
//        }
//      }
//    }
  })
});
