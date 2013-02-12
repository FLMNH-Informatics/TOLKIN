//= require <page>
//= require <html_loader>
//= require <forms_helper>
//= require <templates/tooltip>
//= require <molecular/insd/seq>
//= require <molecular/insd/seqs/taxon_name_auto_text_field>
//= require <molecular/new_mol_marker>
//= require <molecular/get_seqs_from_filename>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('ShowFromFastaPage', {
    isa: Page,
    has: {
      title:          { is: 'ro', init: 'Sequences from FASTA' },
      canRender:      { is: "ro", init: true },
      savable:        { is: 'ro', init: true },
      width:          { is: 'ro', init: 900 },
      saveButtonText: { is: 'ro', init: 'Save' },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_from_fasta_project_molecular_sequences_path'
      }, this ) } },
      seqIds:          { is: 'rw' },
      fastaFilenameId: { is: 'rw' },
      jsonSeqs:        { is: 'rw' }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"].saveButton': function  () {
            var form = $$('form.edit_molecular_insd_seq');
            me.notifier().working('Saving sequence...')
            if (form[0]) {
              form[0].request({
                onSuccess: function (response){
                  if (response.responseJSON){
                    if (response.responseJSON.errormsg){me.notifier().error(response.responseJSON.errormsg)}
                  }else{
                    me.notifier().success('Sequence saved successfully.')
                  }
                }
              })
            }else{ me.notifier().warn('You must first select a filename.')}
          }
        }).call(this, event)
      },
      onChange: function(event){
        if (event.element() == $('fasta_filename_id')){
          this.notifier().working('Fetching sequence...')
          get_seqs_from_filename(this, event.element().value, $('fasta_seq_display_type').down('input[type="radio"][checked="true"]').value)
        }
      },
      getSeq: function(page,index){
        params['id'] = page._seqIds[index]
        new Ajax.Request(page.route('project_molecular_sequence_path'), {
          method: 'get',
          requestHeaders: { Accept: 'text/html' },
          onSuccess: function (response){
            $('show_seq_container').innerHTML = response.responseText
            page.notifier().success('Received sequence(s)')
          },
          onFailure: function (response){},
          onComplete:function (response){}
        })
      }
    }
  })
})