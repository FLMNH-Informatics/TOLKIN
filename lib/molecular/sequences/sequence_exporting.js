JooseRole('SequenceExporting', {
  methods: {
    onClick: function (event) {
        var me = this
          , wndw = this.frame().viewport().widgets().get('window');

      Event.delegate({

      }).call(this,event)
    },

    createAlignment: function (params) {
      if ((params['ids'] && params['ids'].split(',').length != 0) || (params['cell_ids'] && params['cell_ids'].split(',').length != 0)) {
        var me = this;
        me.notifier().working('Working...')
        new Ajax.Request(me.route('show_create_alignment_project_molecular_sequences_path'), {
          method: 'post',
          parameters: params,
          onSuccess: function (response){
            if (response){
              me.frame().viewport().widgets().get('window').loadPage('show_create_alignment_project_molecular_sequences_path');
              me.frame().viewport().widgets().get('window')._page.setSequences(response.responseJSON.seq_ids);
              me.frame().viewport().widgets().get('window')._page.setHtmlToRender(response.responseJSON.html_to_render);
              me.frame().viewport().widgets().get('window')._page.setMatrix_id(params['id']);
              me.notifier().hide();
            }
          }
        })
      }else{this.notifier().error('Nothing is selected.')}
    },
    
    exportSelectedSeqs: function (params) {
      var ids;
      if (params["cell_ids"]) ids = params["cell_ids"];
      if (params["seq_ids"])  ids = params["seq_ids"];
      if (ids.split(',').length != 0) {
        var me = this;
        me.notifier().working('Creating FASTA file...')
        new Ajax.Request(me.route(params["cell_ids"] ? 'export_from_cells_project_molecular_sequences_path' : 'export_from_seqs_project_molecular_sequences_path'), {
          method: 'post',
          parameters: {"ids": ids},
          onSuccess: function (response) {
            window.location = me.context().routes().pathFor('get_fasta_project_molecular_sequences_path') + "?fpath=" + response.responseJSON.fpath.toString();
            me.notifier().success('File created. Sending...')
          }
        })
      }else{this.notifier().error('Nothing is selected.')}
    }
  }
})