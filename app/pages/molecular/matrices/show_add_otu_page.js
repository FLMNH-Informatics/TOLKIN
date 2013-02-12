//= require <page>
//= require <html_loader>
//= require <molecular/matrix>
//= require <molecular/matrices/otu_name_auto_text_field>

JooseModule('Molecular.Matrices', function () {
  JooseClass('ShowAddOtuPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 450 },
      width:          { is: 'ro', init: 500 },
      title:          { is: 'ro', init: "Matrix:  Add OTU"},
      records:        { is: 'ro', lazy: true, init: function () { return $Records({
        matrix: new Molecular.Matrix({id: this.context().params().id, context: this.context()})
      }, this)} },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Add OTU'},
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_otu_project_molecular_matrix_path'
      }, this ) } },
      widgets:        { is: 'ro', init: function () { return $Widgets({
        otuNameField: new Molecular.Matrices.OtuNameAutoTextField({
          object: this.record('otu'),
          parent: this.frame()
        })
      }, this )}}
    },
    methods: {
      onClick: function (event) {
        Event.delegate({
          'input[type="button"][value="Add OTU"]': function (event) {
            this.request(this.frame().element().down('form'));
          }
        }).call(this, event);
      },
      onSubmit: function (event) {
        event.stop();
        this.request(event.element());
      },
      request: function (form) {
        var me = this;
        this.notifier().working('Adding OTU(s) to matrix');
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close();
            if (transport.responseJSON){
              if (transport.responseJSON.message){
                me.notifier().error(transport.responseJSON.message);
              }else{
                $('otus_list').replace(transport.responseJSON.otu_list)//({bottom: transport.responseJSON.rows})
                me.notifier().success('OTU(s) successfully added to matrix.')
              }
            }
            else{
              me.notifier().success('OTU(s) successfully added to matrix.');
//              Morphology.Matrix.fire('recordUpdated', { id: me.params().id });
//              window.location.reload();
            }
          },
          onFailure: function (transport) {
            me.frame().close();
            me.notifier().error("ERROR");
          }
        })
      }
    }
  })
});