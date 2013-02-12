//= require <templates/combo_box>

JooseModule('Taxa', function () {
  JooseClass('ParentComboBox', {
    isa: Templates.ComboBox,
    has: {
      taxon:   { is: 'ro', required: true, nullable: false },
      object:  { is: 'ro', init: function () { return this.taxon() }},
      method:  { is: 'ro', init: 'parent' },
      width:   { is: 'ro', init: 400 },
//      collectionURI: { is: 'ro', init: function () { return Route.forPathname('project_taxa_path') } },
      valueMethod:   { is: 'ro', init: 'taxon_id' },
      textMethod:    { is: 'ro', init: 'label' },
      searchMethod:  { is: 'ro', init: 'name' },
      tagName:       { is: 'ro', init: 'taxon[parent_taxon_id][]' },
      collection:    { is: 'ro', init: function () { 
        return Taxon.
          collection({ context: this.context() }).
          select('taxon_id', 'label', 'css_class', 'namestatus_id').
          include({ namestatus: { select: [ 'id', 'status' ] } }).
          where(this.params().id ? SyncRecord.attr('id').ne(this.params().id) : null)
      } }//,
//      where:         { is: 'ro', init: function () { return () } },
//      options: { is: 'ro', init: function () { return {
//            parameters: {
//              select:  'label, css_class, namestatus.status',
//              include: 'namestatus'//,
////              conditions: this.params().id ? this.params().id+'[^id]' : ''
//            }
//          }
//        }
//      }
    }
  })
});