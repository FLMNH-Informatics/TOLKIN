//= require <page>
//= require <taxa/user_panel>
//= require <taxa/tree_view>
//= require <taxon>

JooseModule('Taxa', function() {
  JooseClass('TreeViewPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//       records: { is: 'ro', lazy: true, init: function () { return $RSet({
//         rootTaxa:
//           Taxon.collection({ context: this.context() })
//             .where(SyncRecord.attribute('parent_taxon_id').eq('null'))
//             .select([ 'taxon_id', 'name', 'has_children'])
//       }, this)}},
      widgets:   { is: 'rw', lazy: true, init: function () { return($WSet({
          treeView:
            new Taxa.TreeView({
              parent: this.frame(),
              context: this.context(),
              rootTaxa: 
                Taxon.collection({ context: this.context() })
                  .where(SyncRecord.attribute('parent_taxon_id').eq('null'))
                  .select([ 'taxon_id', 'name', 'has_children','namestatus_id'])
                  .include({'namestatus': {'select': ['id','status']}})
            }),
          userPanel: new Taxa.UserPanel({ parent: this.frame().viewport(), context: this.context() })
      }, this))}},
      templates: { is: 'ro', lazy: true, init: function () { return($TSet([
          'widgets/_combo_box',
          'layouts/window',
          'widgets/_catalog',
          'widgets/catalogs/_entry',
          'shared/_generic_dialog',
          'shared/_list_citations_taxa',
          'shared/_yes_no_dialog',
          'taxa/tree_views/_action_panel',
          'taxa/show',
          'taxa/_node',
          'taxa/_taxon_details'
      ], this))}}
    }
  })
});
