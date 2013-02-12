//= require <templates/action_panel>
//= require <molecular/insd/seq>
//= require <widget>
//= require <widgets/templates/tooltip>
//= require <molecular/sequences/sequence_exporting>

Module('Molecular.Insd.Seqs.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Templates.ActionPanel,
    does: SequenceExporting,
    has: {
      buttons: { is: 'ro', init: function () { return [
        { label: 'Create',                img: { src: '/images/small_addnew.gif' }, imode: 'edit' },
        { label: 'Import from FASTA',     img: { src: '/images/sm_upload.png'    }, imode: 'edit' },
        { label: 'Delete',                img: { src: '/images/small_cross.png'  }, imode: 'edit' },
        { label: 'Export FASTA',          img: { src: '/images/small_import.png' }, imode: 'edit' },
        { label: 'Create alignment',      img: { src: '/images/align16.png'      }, imode: 'edit' }, //TODO: create a browse version that doesn't save to database, but still exports text
        { label: 'Edit FASTA Sequences',  img: { src: '/images/small_addnew.gif' }, imode: 'edit' }

      ] } },
      catalog: { is: 'ro', init: function () { return this.parent() } }
    },
    methods: {
      onClick: function(event) {
        var me = this
          , wndw = this.viewport().widgets().get('window');
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Create':
                wndw.loadPage('new_project_molecular_sequence_path');
              break;
              case 'Import from FASTA':
                wndw.loadPage('new_project_molecular_import_fasta_seq_path');
              break;
              case 'Export FASTA':
                this.requireSelection(function(){
                  this.exportSelectedSeqs({seq_ids: me.catalog().selected().toString()});
                });
              break;
              case 'Create alignment':
                this.requireSelection(function(){
                  var me = this;
                  me.notifier().working('Working...');
                  var seqIds = me._parent._parent._page._selectedTolkin;
                  new Ajax.Request(me.route('show_create_alignment_project_molecular_sequences_path'), {
                    method: 'get',
                    parameters: { conditions: me.catalog().selected().toString() },
                    onSuccess: function (response){
                      if (response){
                        wndw.loadPage('show_create_alignment_project_molecular_sequences_path');
                        wndw._page.setSequences(seqIds);
                        wndw._page.setHtmlToRender(response.responseJSON.html_to_render);
                        me.notifier().hide();
                      }
                    }
                  })
                })
              break;
              case 'Delete':
                this.requireSelection(function(){
                  var seq = new Molecular.Insd.Seq({ context: this.context() });
                  seq.deleteSelected({collectionString: 'sequence(s)'});
                });
              break;
              case 'Edit FASTA Sequences':
                wndw.loadPage('show_from_fasta_project_molecular_sequences_path')
              break;
            }
          }
        }).call(this, event)
      }
    }
  })
});
