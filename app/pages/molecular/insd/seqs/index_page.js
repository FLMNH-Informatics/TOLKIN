//= require <page>
//= require <molecular/insd/seqs/catalog>
//= require <molecular/insd/seqs/user_panel>
//= require <molecular/insd/seq>
//= require <seq_search/toggle_seq_search>
//= require <seq_search/genbank_esearch>
//= require <seq_search/genbank_seq_display>

Module('Molecular.Insd.Seqs', function() {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      widgets:   { is: 'ro', lazy: true, init: function () { return $WSet({
        catalog: new Molecular.Insd.Seqs.Catalog({
          parent: this.frame(),
          collection:
             Molecular.Insd.Seq.collection({ context: this.context() })
        }),
        userPanel: new Molecular.Insd.Seqs.UserPanel({ parent: this.frame().viewport() })
      }, this )  }},
      templates: { is: 'ro', lazy: true, init: function () { return $TSet([
        'ncbi/seqs/index',
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'
      ], this )  } },
      searchTerm:     { is: 'rw', init: null },
      sequences:      { is: 'rw' },
      seqStart:       { is: 'rw', lazy: true, init: 0 },
      seqRowLimit:    { is: 'rw', lazy: true, init: 20 },
      seqColumns:     { is: 'ro', lazy: true, init: ['Organism', 'Link', 'Locus', 'Marker', 'Definition', 'Sequence'] },
      selectedSeqs:   { is: 'rw', init: [] },
      webenv:         { is: 'rw', lazy: true, init: '' },
      querykey:       { is: 'rw', lazy: true, init: '' },
      resultsCount:   { is: 'rw', lazy: true, init: null }
    },
    after: {
      initialize: function () {
        var me = this;
        this.iMode().on('change', function () {
          if ( me.interactMode()._value == 'browse' ) {
            $('add_genbank_seq').setStyle('display: none;');
          }else{
            $('add_genbank_seq').setStyle('display: inline;');
          }
        })
      }
    },
    methods: {
      onClick: function (event) {
        var me = this
          , elem = event.element()
          , elementActionPanel = 'viewport_content_frame_molecular_insd_seqs_catalog_molecular_insd_seqs_catalogs_action_panel';

        if (elem.hasAttribute('tool')) {
          var tool = elem.readAttribute('tool');
          if (['beginning','end','step_back','step_forward'].indexOf(tool) != -1) {
            if (!elem.hasClassName('inactive')){
              changeResults(this, tool);
            }
          }
          switch (tool){
            case 'toggle_search':
              toggleSearch(elem);         //switch between genbank search and tolkin catalog lib/seq_search/toggle_seq_search.js
            break;
            case 'esearch':
              me.setSeqStart(0);
              me.setSeqRowLimit(20);
              me.setWebenv('');
              me.setQuerykey('');
              eSearch($('genbank_term').value.strip(), this);  //search genbank lib/seq_search/genbank_esearch.js
            break;
            case 'unselect_all_seqs':
                unselectAllSeqs(this); //unselect seqs (removes from js memory) lib/seq_search/genbank_seq_display.js
            break;
            case 'seq_check':
              if (event.shiftKey == true){
                me.shiftCheck(event, me).each(function (chk) { toggleSeq(me, chk) });
              }
              toggleSeq(this, elem);
            break;
            case 'check_all':
              var checked = $('genbank_results').down('input.check_all').checked;
              $('genbank_results').select('input[tool=seq_check]').each(function(chk){
                chk.checked = checked;
                toggleSeq(me, chk); //toggle's checked seqs in js memory lib/seq_search/genbank_seq_display.js
              })
            break;
            case 'add_genbank':  //opens window to add to tolkin from genbank
              if (this._selectedSeqs.length != 0) {
                var seqs = this._selectedSeqs.collect(function(s){return Object.toQueryString(s)});
                var window = this.context().viewport().widget('window');
                window.loadPage('show_add_genbank_markers_project_molecular_sequences_path');
                window._page.setSequences(this._selectedSeqs.sortBy(function (s){ return s.marker ? s.organism : '0' }));
              }
            break;
            case 'toggle_genbank_inputs':
              toggleGenbankInputs(); //show more or less searching options lib/seq_search/genbank_seq_display.js
            break;
          }
        }
        Event.delegate({
          'input:checkbox': function (event) {
            if (!event.element().hasAttribute('tool')) {
              if (!event.element().hasClassName('check_all')){
                me.shiftCheck(event); //shift+checking multiple checkboxes functionality (ilib/shift_checking.js)
              }
            }
          }
        }).call(this, event)
      }
    }
  })
})

