//= require <toljs/role/savable_display>
//= require <widgets/templates/window>
//= require "taxon_combo_box"
//= require "collection_combo_box"

Module('Widgets.Molecular.Primers', function() {
  JooseClass('Window', {
    isa: Widgets.Templates.Window,
    does: [ TOLJS.role.SavableDisplay ],
    has: {
      collection: { is: 'rw'},
      pageFactory: { is: 'ro', init: function () { return new TOLKIN.PageFactory( { frame: this }) } },
      title: {
        is: rw,
        init: 'Primer',
        nullable: false
      },
      primer: {
        is: rw,
        required: true,
        nullable: false
      }/*,
      widgets: { is: 'ro', init: function () { return($Reg({
            taxonComboBox: new Widgets.Molecular.DnaSamples.TaxonComboBox({ parent : this, object: this.collection()}),
            collectionComboBox: new Widgets.Molecular.DnaSamples.CollectionComboBox({ parent : this, object: this.collection()})
      }, this) )}}*/
    },
    before: {
      destroy: function() {
        this.widgets().get('taxonComboBox').destroy();
        this.widgets().get('collectionComboBox').destroy();
      }
    },
    override: {
      onClick: function(event) {
        var window = this;
        Event.delegate({
          "input[type='submit']": function(event) {
            event.stop();
            this.working();
            this.dnaSample.update(event.element().up('form').serialize({
              hash: true,
              submit: false
            }), {
              onSuccess: function() {
                window.success();
              }
            });
          },
          'html': this.SUPER(event)
        }).bind(this)(event);
      },
      render: function() {
        this.SUPER({ yield: this.contents });
        var opts1 = {
          formElements:{
            "date_received_Y":"Y",
            "date_received_mm":"m",
            "date_received_dd":"d"
          },
          showWeeks:true,
          statusFormat:"l-cc-sp-d-sp-F-sp-Y",
          positioned:"date_received_button_wrapper"
        };
        var opts2 = {
          formElements:{
            "date_extracted_Y":"Y",
            "date_extracted_mm":"m",
            "date_extracted_dd":"d"
          },
          showWeeks:true,
          statusFormat:"l-cc-sp-d-sp-F-sp-Y",
          positioned:"date_extracted_button_wrapper"
        }
        datePickerController.createDatePicker(opts1);
        datePickerController.createDatePicker(opts2);
        return this;
      }
    },
    methods: {
      loadContents: function(options) {
        var window = this;
        var path = this.dnaSample() ? this.dnaSample().requestPath() : this.session().routes().getModelRoute('Primer')+'/new';
        new Ajax.Request(path, {
          method: 'get',
          onSuccess: function(transport) {
            window.contents = transport.responseText;
            if(options.onSuccess) {
              options.onSuccess();
            }
          }
        });
      }
    }
  })
});

