//= require <page>
//= require <html_loader>
//= require <seq_search/genbank_seqs_for_addition>


JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('ShowAddGenbankMarkersPage', {
    isa: Page,
    has: {
      title:          { is: 'ro', init: 'Genbank Sequences' },
      canRender:      { is: "ro", init: true },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Save sequences' },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_genbank_markers_project_molecular_sequences_path'
      }, this ) } },
      sequences:      { is: 'rw', init: null },
      dontsave:       { is: 'rw', init: [] }
    },
    after: {
      onLoad: function ()  {
        this.renderSeqs();
      }
    },
    methods: {
      onClick: function (event) {
        var conftext = ""
          , me = this;
        Event.delegate({
          'input[type="button"]': function (event) {
            switch (event.element().readAttribute('value')) {
              case 'Save sequences':
                var seqs = this.collectSeqs()
                  , all_seqs = seqs.collect(function(seq){return Object.toJSON(seq)});
                me.notifier().working('Saving chosen Genbank sequences to Tolkin...');
                if (seqs.length > 0){
                  new Ajax.Request('/projects/' + params['project_id'] + '/molecular/sequences/new_from_genbank', {
                    method: 'post',
                    parameters: { 'seqs[]': all_seqs },
                    onSuccess: function (response) {
                      var counts = response.responseJSON.counts;
                      var msg = counts.num_seqs.toString() + ' sequence(s) successfully added.  ';
                      if (counts.num_tax != 0) {
                        msg = msg + counts.num_tax + ((counts.num_tax == 1) ? ' taxon' : ' taxa') + ' also added.  ';
                      }
                      msg = msg + ((counts.already != 0) ? (counts.already + ' sequence(s) already existed.  ') : '');
                      new Molecular.Insd.Seq({ context: me.context() }).fire('create');
                      toggleSearch($('tolkin_seq_search'));
                      me.notifier().success(msg);
                      me.frame().close();
                    },
                    onFailure: function (response) {
                      me.notifier().error('Sorry, something went wrong. ');
                    },
                    onComplete: function (response) {}
                  })
                }
              break;
            }
          },
          'a.undo_remove': function (event) {
            var seqid = event.element().id.split('_')[1]
              , seq   = me._sequences[seqid];
            me.setDontsave(me._dontsave.without(seq));
            me.renderSeqs();
          },
          'a.remove_seq': function (event) {
            var row   = event.element().up(2)
              , seq_index = parseInt(row.id.split('_')[1])
              , seq   = me._sequences[seq_index];
            me._dontsave.push(seq);
            me.renderSeqs();
          },
          'a.cancel_seqs_for_addition': function () {
            me.frame().close();
          }
        }).call(this, event)
      },
      collectSeqs: function () {
        return this._sequences.collect(function (seq){
          if (this._dontsave.indexOf(seq) == -1) {
            return seq;
          }
        }, this).compact();
      },
      renderSeqs: function () {
        $('seqs_for_addition').innerHTML = displayGenbankSeqs(this).join(''); //lib/seq_search/genbank_seqs_for_addition.js
      }
    }
  })
})