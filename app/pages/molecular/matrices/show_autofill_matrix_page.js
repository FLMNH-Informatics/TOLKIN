//=require <page>
//=require <html_loader>

JooseModule('Molecular.Matrices', function () {
  JooseClass('ShowAutofillMatrixPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: 'true' },
      height:    { is: 'ro', init: 80 },
      width:     { is: 'ro', init: 400 },
      title:     { is: 'ro', init: "Autofill matrix"},
      savable:   { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Autofill' },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_autofill_matrix_project_molecular_matrix_path'
      }, this )}}
    },
    methods: {
      onClick: function (event){
        var me = this
          , showpage = me.context().viewport().designatedFrame().page()
          , matrix = showpage.matrixInfo();
        Event.delegate({
          'input[type="button"][value="Autofill"]': function (event) {
            me.notifier().working('Filling matrix...');
            new Ajax.Request(me.context().routes().pathFor('autofill_matrix_project_molecular_matrix_path'), {
              method: 'post',
              parameters: {"status": $('cell_status_id').value},
              onSuccess: function(response){
                me.notifier().success('Matrix filled.')
              }
            });
            setTimeout(function(){
              window.location.reload();
            }, 2000)
          }
        }).call(this,event);
      }
    }
  });
});