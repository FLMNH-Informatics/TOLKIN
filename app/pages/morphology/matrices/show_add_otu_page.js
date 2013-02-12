//= require <page>
//= require <html_loader>
//= require <morphology/matrix>
//= require <morphology/matrices/otu_name_auto_text_field>

JooseModule('Morphology.Matrices', function () {
  JooseClass('ShowAddOtuPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      height:         { is: 'ro', init: 450 },
      width:          { is: 'ro', init: 500 },
      title:          { is: 'ro', init: "Matrix:  Add OTU"},
      records:        { is: 'ro', lazy: true, init: function () { return $Records({
            matrix: new Morphology.Matrix({ context: this.context(), data: {} })
      }, this)} },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Add OTU'},
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_otu_project_morphology_matrix_path'
      }, this ) } },
      widgets:        { is: 'ro', init: function () { return $Widgets({
        otuNameField: new Morphology.Matrices.OtuNameAutoTextField({
          object: this.record('otu'),
          parent: this.frame()
        })
      }, this )}}
    },
    methods: {
      onClick: function (event) {
        Event.delegate({
          'input[type="button"][value="Add OTU"]': function (event) {
            this.request(this.frame().element().down('form'))
          }
        }).call(this, event)
      },
      onSubmit: function (event) {
        event.stop()
        this.request(event.element())
      },
      request: function (form) {
        var me = this
        this.notifier().working('Adding OTU(s) to matrix')
        form.request({
          requestHeaders: ["Accept", "application/json"],
          onSuccess: function (transport) {
            me.frame().close()
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
            }
          },
          onFailure: function (transport) {
            me.frame().close()
            me.notifier().error("ERROR")
          }
        })
      }
    }
  })
})