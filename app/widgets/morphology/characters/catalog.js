//= require <templates/catalog>
//= require <morphology/character>
//= require "catalogs/action_panel"

Module('Morphology.Characters', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      collectionClass: { is: 'ro', init: function () { return Morphology.Character } },
      collectionName: { init: 'morphology::character' },
      collection: { is: 'rw', required: true, nullable: false },
      columns: { init: function () {
          return [
            { attribute: "name", width: 250 },
            { attribute: "short_name", label: "Short name", width: 250 },
            { attribute: "chr_groups_joined", label: "Chracter Groups", map: "name", width: 250 },
            { attribute: "creator.user.label", label: 'Owner', width: 150 }
          ]}},
          widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Morphology.Characters.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
    override: {
      _columnValue: function (item, column) {
        if(column.attribute == 'chr_groups') {
          return item.characters_chr_groups.characters_chr_groups.inject('', function(acc, characters_chr_groups_entry) {
            return acc+characters_chr_groups_entry.chr_group.name
          })
        } else {
          return this.SUPER(item, column)
        }
      },
      onRowClick: function (event) {
        var chrId = event.element().up('.row').readAttribute('data-id');
        window.location.pathname = this.context().routes().pathFor('project_morphology_character_path', { id: chrId });
//        this.viewport().widget('window').loadPage('project_morphology_character_path', {id: chrId });
      }
    }
//    ,
//     methods: {
//      onClick: function (event) {
//        if(!(event.element().readAttribute('type') == 'checkbox') && !event.element().down("type['checkbox']")) {
//          var chrId = event.element().up('.row').readAttribute('data-id');
//          window.location.pathname = "/projects/" + params['project_id'] + "/characters/" + chrId;
//        }
//      }
//    }
  })
});

