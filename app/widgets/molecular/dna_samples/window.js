////= require <roles/savable_display>
////= require <templates/window>
////= require "taxon_combo_box"
////= require "collection_combo_box"
//
//Module('Molecular.DnaSamples', function() {
//  JooseClass('Window', {
//    isa: Templates.Window,
//    does: [ TOLJS.role.SavableDisplay ],
//    has: {
//      collection: { is: 'rw'},
//      title: {
//        is: rw,
//        init: 'Dna Sample',
//        nullable: false
//      },
//       savable     : { is: 'ro', init: true },
//      dnaSample: {
//        is: rw,
//        required: true,
//        nullable: false
//      },
//      widgets: { is: 'ro', init: function () { return($Reg({
//            taxonComboBox: new Molecular.DnaSamples.TaxonComboBox({ parent : this, object: this.dnaSample()}),
//            collectionComboBox: new Molecular.DnaSamples.CollectionComboBox({ parent : this, object: this.dnaSample()})
//      }, this) )}}
//    },
//    override: {
//      onClick: function(event) {
//        var window = this;
//        Event.delegate({
//          ".saveButton.active": function(event) {
//            var form = event.element().up('.dialog').down('.edit_dna_sample');
//            this.working();
//            this.dnaSample().update(form.serialize({
//              hash: true,
//              submit: false
//            }), {
//              requestHeaders: { Accept: 'application/json' },
//              onSuccess: function() {
//                window.success();
//              }
//            });
//          },
//          'html': this.SUPER(event)
//        }).bind(this)(event);
//      },
//      render: function() {
//        this.SUPER({ yield: this.contents });
//        var opts1 = {
//          formElements:{
//            "date_received_Y":"Y",
//            "date_received_mm":"m",
//            "date_received_dd":"d"
//          },
//          showWeeks:true,
//          statusFormat:"l-cc-sp-d-sp-F-sp-Y",
//          positioned:"date_received_button_wrapper"
//        };
//        var opts2 = {
//          formElements:{
//            "date_extracted_Y":"Y",
//            "date_extracted_mm":"m",
//            "date_extracted_dd":"d"
//          },
//          showWeeks:true,
//          statusFormat:"l-cc-sp-d-sp-F-sp-Y",
//          positioned:"date_extracted_button_wrapper"
//        }
//        datePickerController.createDatePicker(opts1);
//        datePickerController.createDatePicker(opts2);
//        return this;
//      }
//    },
//    methods: {
//      loadContents: function(options) {
//        var window = this;
//        var path = this.dnaSample() ? this.dnaSample().requestPath() : this.session().routes().getModelRoute('DnaSample')+'/new';
//        new Ajax.Request(path, {
//          method: 'get',
//          onSuccess: function(transport) {
//            window.contents = transport.responseText;
//            if(options.onSuccess) {
//              options.onSuccess();
//            }
//          }
//        });
//      }
//    }
//  })
//});
//
