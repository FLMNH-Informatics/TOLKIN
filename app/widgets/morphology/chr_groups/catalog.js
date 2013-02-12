//= require <templates/catalog>
//= require <morphology/chr_group>
//= require "catalogs/action_panel"

Module('Morphology.ChrGroups', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {  
//      collectionClass: { is: 'ro', init: function () { return Models.Morphology.ChrGroup } },
//      collectionName: { init: 'morphology::ChrGroup' },
      columns: { init: function () {
          return [
            { attribute: "name", width: 250 },
            { attribute: "perspective", width: 150 },
            { attribute: "sensor", width: 150 },
            { attribute: "owner.label", label : 'Owner',width: 150 }
          ]}},
          widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Morphology.ChrGroups.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
//    after: {
//      initialize: function(){
//                new TOLKIN.views._Filter({parent: this, catalog:this});
//      }
//    },
    override: {
     onRowClick: function (event) {
          var chrgrpId = event.element().up('.row').readAttribute('data-id');
          window.location.pathname = this.context().routes().pathFor('project_morphology_chr_group_path', { id: chrgrpId });
        }
    }
//    ,
//     methods: {
//      onClick: function (event) {
//        if(!(event.element().readAttribute('type') == 'checkbox') && !event.element().down("type['checkbox']")) {
//          var chrgrpId = event.element().up('.row').readAttribute('data-id');
//          window.location.pathname = "/projects/" + params['project_id'] + "/chr_groups/" +chrgrpId;
//        }
//      }
//    }
  })
});

