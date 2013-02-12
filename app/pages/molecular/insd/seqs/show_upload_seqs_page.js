//= require <page>
//= require <html_loader>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('ShowUploadSeqsPage', {
    isa: Page,
    has: {
      title:          { is: 'ro', init: 'Upload Sequences' },
      canRender:      { is: "ro", init: true },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Upload' },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_upload_seqs_project_molecular_sequences_path'
      }, this ) } }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"].saveButton': function  () {
            $$('form')[0].submit()
          }
        }).call(this, event)
      }
    }
  })
})