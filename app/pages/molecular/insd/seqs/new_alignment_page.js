//= require <page>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('NewAlignmentPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'New Alignment' },
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'insd/seqs/_new_alignment_window',
        'molecular/alignments/show'
      ],this) }}
    },
    methods: {
      renderToString: function () {
        return this.context().templates().get('insd/seqs/_new_alignment_window').evaluate({
          form_action   : this.context().routes().pathFor('align_project_molecular_sequences_path'),
          'seq_ids()': this.context().params().ids
        })
      },
      onChange: function (event) {
        var el = event.element();
        if(el.readAttribute('class') == 'select') {
          var id = el.readAttribute('id');
          if(el.value == 'new'){
             $( id + '_new').disabled = false;
          }else{
             $( id + '_new').disabled = true;
          }
        }
      },
      onSubmit: function (event) {
        event.stop();
        var me = this;
        new Ajax.Request(this.context().routes().pathFor('align_project_molecular_sequences_path'), {
          parameters: event.element().serialize(),
          onSuccess: function (transport) {
             me.frame().loadPage('project_molecular_alignment_path', {id: transport.responseJSON.id});
          }
        });
      }
    },
    after: {
      initialize: function () {
        var me = this;
      }

    }//,
    //override: {
      //renderToString: function() {
        //var evaluated = this.context().templates().get('insd/seqs/_new_alignment_window').evaluate({
           //form_action   : this.context().routes().pathFor('project_molecular_sequences_path')

        //});
        //return evaluated;
      //}
    //}
  })
})
