//= require <templates/catalog>
//= require <molecular/primer>
//= require <molecular/primers/catalogs/action_panel>
//= require <templates/catalogs/filter_set>

Module('Molecular.Primers', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has:{
      columns: { init: function () { return [
        { attribute: 'name', label:'Primer Name', width: 180 },
        { attribute: 'taxon.taxon.name', label:'Target Organism', width: 180 },
        { attribute: 'marker.marker.name', label:'Target Organism', width: 180 },
        { attribute: 'purification_method.purification_method.name', label:'Purification Method', width: 180 }
      ] } },
      widgets: { is: 'ro', init: function () { return $Widgets({
        actionPanel: new Molecular.Primers.Catalogs.ActionPanel({ parent: this }),
        filterSet:   new Templates.Catalogs.FilterSet({context: this.context(), parent: this, catalog: this})
      }, this ) } }
    },
    methods: {
      onRowClick: function (event) {
        var id = event.element().up('.row').readAttribute('data-id');
        this.viewport().widget('window').loadPage('project_molecular_primer_path', { id: id });
//        this.context().currentSelection().set({type: 'Primer', id: id, label: event.element().innerHTML});
//        params['id'] = id;
//        var window = this.viewport().widgets().get('window');
//        var queue = new Queue();
//
//        queue.join( window.loadPage('project_molecular_primer_path', {id: params['id'], queue: queue}));
//        queue.add( window.show.bind(window));
//        queue.flush();
      }
    }
  })
})
