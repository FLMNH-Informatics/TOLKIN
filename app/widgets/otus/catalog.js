//= require <templates/catalog>
//= require <otu>
//= require <otus/catalogs/action_panel>

JooseModule('Otus', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      collectionClass: { is: 'ro', init: function () { return Otu } },
      collectionName: { init: 'otu' },
      collection: { is: 'rw', required: true, nullable: false },
      columns: { init: function () { return [ 
        { attribute: "name", width: 250 },
        { attribute: "otu_groups_joined", label: 'OTU groups joined', width: 200 },
//        { attribute: "otu_groups.otu_groups", map: 'name', width: 200 },
        { attribute: "creator.user.label", label: 'Owner', width: 150 }
      ] }},
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Otus.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
    override: {
//      _columnValue: function (item, column) {
//        if(column.attribute == 'otu_groups') {
//          return item.otu_groups_otus.inject('', function(acc, otu_groups_otus_entry) {
//            return acc+otu_groups_otus_entry.otu_group.name
//          })
//        } else {
//          return this.SUPER(item, column)
//        }
//      },
      onRowClick: function (event) {
          var otuId = event.element().up('.row').readAttribute('data-id');
          window.location.pathname = this.context().routes().pathFor('project_otu_path', { id: otuId });
      }
    }
  })
});
