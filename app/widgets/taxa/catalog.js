//= require <templates/catalog>
//= require <templates/window>
//= require "catalogs/action_panel"
//= require <taxon>
//= require <roles/modified_scheduler>

Module('Taxa', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    does: [ Roles.ModifiedScheduler ],
    has: {
      collectionClass: { is: 'ro', init: function () { return Taxon } },
      collectionName: { init: 'taxon' },
      filterFormId: { is: 'ro', init: 'list_items_form' },
      dataId: { is: 'ro', init: 'taxon_id' },
      columns: { init: function () {
          return [
            { attribute: "name",                                         width: 250, cssClass: 'css_class' },
            { attribute: "author",                                       width: 150, cssClass: 'css_class' },
            { attribute: "publication",      label: 'Publication Title', width: 200, cssClass: 'css_class' },
            { attribute: "volume_num",       label: 'Volume',            width: 50,  cssClass: 'css_class' },
            { attribute: "pages",                                        width: 50,  cssClass: 'css_class' },
            { attribute: "publication_date", label: 'Pub. Date',         width: 50,  cssClass: 'css_class' }
          ]}},
    widgets: { is: 'ro', init: function () { return $Reg({
        actionPanel: new Taxa.Catalogs.ActionPanel({parent: this}),
        filterSet: new Templates.Catalogs.FilterSet({ parent: this, catalog: this, context: this.context()})
      }, this) } },
      collection: { is: 'rw', required: true, nullable: false }
    },
    after: {
      initialize: function () {
        if ($(this.id())) {
          this.selected().deselectAll()
        }
      }
    },
//    after: {
//      initialize: function () {
//        var me = this
//        this.page().on('loaded', function () {
//          this.interactMode().addObserver(this, function () {
//            me.widget('actionPanel').refresh()
//          })
//        }, this)
//        this.after('initialize')
//      }
//    },
    override: {
      onRowClick: function(event) {
        var id = event.element().up('.row').readAttribute('data-id');
//        this.context().currentSelection().set({type: 'Taxon', id: id, label: event.element().innerHTML});
        if(params['public_user']) {
          var action = Route.forPathname('project_taxon_path').buildInterpolatedPath(Object.extend(params, { id: id }))
          var form = document.createElement("form")
          form.method = "GET"
          form.action = action
          form.target = "_blank"
          document.body.appendChild(form)
          form.submit()
        } else {
          var window = this.viewport().widgets().get('window')
          window.loadPage('project_taxon_path', { id: id }) //, queue: queue}) //FIXME: get rid of taxon_id / id duplication
        }
      }
    }
  })
});

