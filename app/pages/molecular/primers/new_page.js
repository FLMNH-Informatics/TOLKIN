//= require <page>
//= require <molecular/primers/taxon_auto_complete_field>
//= require <molecular/primer>
//= require <molecular/primers/marker_auto_complete_field>
//= require <molecular/primers/purification_method_auto_complete_field>
//= require <roles/polling>

//FIXME: needs to be updated
JooseModule('Molecular.Primers', function () {
  JooseClass('NewPage', {
    isa: Page,
    does: Polling,
    has: {
      canRender:  { is: 'ro', init: true },
      title:      { is: 'ro', init: 'Primer : New' },
      savable:    { is: 'ro', init: true },
      height:     { is: 'ro', init: 425 },
      width:      { is: 'ro', init: 600 },
      records:    { is: 'ro', lazy: true, init: function () { return $Records({
        primer: new Molecular.Primer({ context: this.context() })
      }, this) } },
      widgets:    { is: 'ro', lazy: true, init: function () { return $Widgets({
        taxon_auto_complete_field: new Molecular.Primers.TaxonAutoCompleteField({
          primer: this.record('primer'),
          parent: this.frame(),
          context: this.context()
//        }),
////        marker_auto_complete_field: new Molecular.Primers.MarkerAutoCompleteField({
////          primer: this.record('primer'),
////          parent: this.frame(),
////          context: this.context()
////        }),
//        purification_method_auto_complete_field: new Molecular.Primers.PurificationMethodAutoCompleteField({
//          primer: this.record('primer'),
//          parent: this.frame(),
//          context: this.context()
        })//,
//        taxon_combo_box: new Molecular.Primers.TaxonComboBox({
//          parent: this.frame(),
//          context: this.context(),
//          object: new Molecular.Primer({ context: this.frame().context() })
//        }),
//        gene_auto_text_field: new Molecular.Primers.GeneAutoTextField({
//          parent: this.frame(),
//          context: this.context(),
//          object: new Molecular.Primer({ context: this.frame().context() })
//        })
      }, this ) } },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_molecular_primer_path'
      }, this ) } }
    },
    methods: {
//       loadold: function () {
//         var me = this;
//         var window = this.frame().viewport().widgets().get('window');
//         new Ajax.Request(this.context().routes().pathFor('get_target_organisms_project_molecular_primers_path'),{
//           method: 'get',
//           onSuccess: function (trans) {
//             window.on('state:pageRendered', (function () {
//               Element.insert($(me.frame().id()).down('select#primer_target_organism'), trans.responseText);
//               $(me.frame().id()).down('select#primer_target_organism').next('.loader').hide();
//             }).bind(this), { once: true })
//           },
//           onComplete: function() {
//             if($('primer_target_organism').value == 'new'){
//                $('primer_target_organism_new').disabled = false;
//             }
//           }
//         });
//         new Ajax.Request(this.context().routes().pathFor('get_genes_project_molecular_primers_path'), {
//           method: 'get',
//           onSuccess: function (trans) {
//             window.on('state:pageRendered', (function () {
//               Element.insert($(me.frame().id()).down('select#primer_gene'), trans.responseText);
//               $(me.frame().id()).down('select#primer_gene').next('.loader').hide();
//             }).bind(this), { once: true })
//           },
//           onComplete: function() {
//             if($('primer_gene').value == 'new'){
//                $('primer_gene_new').disabled = false;
//             }
//           }
//         });
//         new Ajax.Request(this.context().routes().pathFor('get_purification_methods_project_molecular_primers_path'),{
//           method: 'get',
//           onSuccess: function (trans) {
//             window.on('state:pageRendered', (function () {
//               Element.insert($(me.frame().id()).down('select#primer_purification_method'), trans.responseText);
//               $(me.frame().id()).down('select#primer_purification_method').next('.loader').hide();
//             }).bind(this), { once: true })
//           },
//           onComplete: function() {
//             if($('primer_purification_method').value == 'new'){
//                $('primer_purification_method_new').disabled = false;
//             }
//           }
//         });
//       },
//       renderToString: function() {
//         var evaluated =
//         this.context().templates().get('molecular/primers/_new_primer_window').evaluate({
//            form_action   : this.context().routes().pathFor('project_molecular_primers_path')
// 
//         });
//         return evaluated;
//       },

      onClick: function (event) {
        Event.delegate({
          'input[type="button"].active.saveButton': function (event) {
            var me = this
              , weight = $('primer_molecular_weight').value;
            if (isNumber(weight) || weight == ''){
              this.notifier().working('Creating new primer ...');
              $(this.frame().id()).down('form').request({
                requestHeaders: { Accept: 'application/json' },
                onSuccess: function (transport) {
                  me.notifier().success('Primer created successfully.');
                  var primer = new Molecular.Primer({ context: me.context() }).fire('create', { memo: { record: primer } });
                  me.frame().loadPage('project_molecular_primer_path', { id: transport.responseJSON.id });
                },
                onFailure: function (response) {
                  me.notifier().error('Problem encountered: failed to create primer.');
                }
              })
            }else{me.notifier().warning('Molecular weight must be a number')}
          }
        }).call(this, event)
      },

      onChange: function (event) {
        var el = event.element();
        if ( el == $('primer_marker_id') || el == $('primer_purification_method_id') ){
          if(el.value == 'new'){
            if (!el.next().visible()) el.next().toggle()
          }else{
            if (el.next().visible() ) el.next().toggle()
          }
        }
      }
    }
  })
})
