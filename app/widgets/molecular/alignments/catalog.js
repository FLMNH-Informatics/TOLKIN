//= require <templates/window>
////= require <roles/modified_scheduler>
//= require <templates/catalog>
//= require <molecular/alignment>
//= require <molecular/alignments/catalogs/action_panel>
//= require <templates/catalogs/filter_set>

JooseModule('Molecular.Alignments', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
//    does: [ Roles.ModifiedScheduler ],
    has: {
//      limit: { is: 'rw', init: 200, nullable: false },
      columns: { init: function () { return [
            { attribute: 'name', label: 'Name', width: 150 },
            { attribute: 'description', label: 'Description', width: 250 },
            { attribute: 'creator.label', label: 'Owner', width: 100 }
          ]}},
      collection: { is: 'ro', init: function () { return Molecular.Alignment.collection({ context: this.context() })}},
      widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Molecular.Alignments.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } }
    },
    override: {
      onRowClick: function (event) {
        Event.delegate({
          "div['data-id']" : function (event) {
            params['id'] = event.element().up("tr['data-id']").readAttribute('data-id');
            window.location.pathname = '/projects/' + params['project_id'] + '/molecular/alignments/' + params['id'];
          }
        }).bind(this)(event);
      }
    }
  })
});
