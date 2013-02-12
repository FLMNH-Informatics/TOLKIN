//= require <widgets/templates/catalog>
//= require <collection>
//= require "catalogs/action_panel"
//= require "catalogs/filter_set"
//= require <templates/catalogs/filter_set>

Module('Collections', function () {
  JooseClass('Catalog', {
    isa: Templates.Catalog,
    has: {
      columns: { is: 'ro', init: function () { return [
        { attribute: "collector", width: 100 },
        { attribute: "collection_number", label: "Collection Number", width: 100 },
        { attribute: "taxon.taxon.label", label: "Taxon", width: 300, order_on:"taxon.name" },
        { attribute: "country", width: 100 }
      ] } },
      collection: { is: 'rw', required: true, nullable: false },
      widgets: { is: 'ro', init: function () { return $Widgets({
        actionPanel: new Collections.Catalogs.ActionPanel({
          parent: this
        }),
        filterSet: new Collections.Catalogs.FilterSet({
          parent: this,
          catalog: this,
          context: this.context()
        })
      }, this) } }
    },
    override: {
      onRowClick: function(event) {
        //        if(this._inARow(event.element())) {
        //          if(!event.element().up('.checkbox_cell') && !event.element().hasClassName('checkbox_cell')) {
        var dataId = event.element().upper('tr[data-id]').readAttribute('data-id');
//        var collection = new Collection({
//          id: collectionId,
//          context: this.context()
//        });
        this.viewport().widget('window').loadPage('project_collection_path', { id: dataId })
//        var window = new Collections.Window({
//          parent: this.viewport(),
//          context: this.context(),
//          collection: collection
//        });
      //        this.viewport().addWidgets([
      //          window
      //        ]);
      //        window.params().id = collectionId
      //        window.collection().load({
      //          onSuccess: function () {
      //            window.render();
      //            window.display();
      //          }
      //        });
      //      }
      //    }
      }
    }
  })
});

