//= require <page>
//= require <morphology/matrix>
//= require <widgets/morphology/matrices/catalog>
//= require <widgets/morphology/matrices/user_panel>

JooseModule('Morphology.Matrices', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
//       records: { is: 'ro', lazy: true, init: function () { return $RSet({
//         matrices: Morphology.Matrix.collection({context: this.frame().context()})
// //            .include([ 'parent', 'creator', 'object_history' ])
// //            .select([ 'id', 'name', 'description', 'parent.name', 'updater_label', 'updated_at', 'creator.label', 'created_at', 'matrix_id', 'branch_number'])
//       }, this) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        matriceCatalog:
          new Morphology.Matrices.Catalog({
            parent:     this.frame(),
            collection: Morphology.Matrix.collection({context: this.frame().context()}), // this.records().get('matrices'),
            context:    this.frame().context()  })
//        userPanel:
//          new Morphology.Matrices.UserPanel({
//            context: this.context(),
//            parent:  this.frame().viewport()  })
        }, this) } },
      templates: { is: 'ro', lazy: true, init: $TSet([
        'layouts/window',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'//,
        //'morphology/matrices/catalogs/_action_panel'
      ], this) }
    }
//    after: {
//      initialize: function() {
//        $('lnk_del_sel').observe('click', function(event){
//          form = $('list_items_form');
//          form.writeAttribute('action', '/projects/'+ params["project_id"] +'/matrices/delete_selected');
//          form.writeAttribute('method', 'post');
//          form.submit();
//        });
//        $('sp_modify_matrix').observe('click', function(event){
//          $('list_items_form').writeAttribute('action', '/projects/'+ params["project_id"] +'/matrices/process_index_modify_matrix');
//          $('list_items_form').writeAttribute('method', 'post');
//          $('list_items_form').submit()  }) } }
  }) 
})
