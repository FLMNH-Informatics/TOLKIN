//= require <page>
//= require <html_loader>
//= require <molecular/matrix>
//= require <molecular/insd/seqs/seq_catalog>
//= require <seq_search/toggle_seq_search>
//= require <seq_search/genbank_esearch>
//= require <seq_search/genbank_seq_display>
//= require <molecular/matrix/cell/cell_controls>

JooseModule('Molecular.Matrix.Cells', function () {
  JooseClass('ShowCellPage', {
    isa: Page,
    does: CellControls,
    has: {
      canRender:      { is: 'ro', init: true },
      width:          { is: 'ro', init: 980 },
      height:         { is: 'ro', init: 500 },
      title:          { is: 'ro', init: "Molecular Matrix Cell: Show"},
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Update Cell'},
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_cell_project_molecular_matrix_cell_path' }, this ) } },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        catalog: new Molecular.Insd.Seqs.SeqCatalog({
          parent: this.frame(),
          collection: Molecular.Insd.Seq.collection({ context: this.context() })
        })}, this )}},
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'widgets/_catalog',
        'widgets/catalogs/_entry',
        'filters/_form'
      ], this )  } },
      searchTerm:   { is: 'rw', init: null },
      sequences:    { is: 'rw' },
      currentSort:  { is: 'rw', lazy: true, init: 'Locus' },
      seqStart:     { is: 'rw', lazy: true, init: 0 },
      seqRowLimit:  { is: 'rw', lazy: true, init: 10 },
      seqColumns:   { is: 'ro', lazy: true, init: ['Organism', 'Marker', 'Sequence' ] },
      selectedSeqs: { is: 'rw', init: [] },
      seqsToAdd:    { is: 'rw', init: [] },
      webenv:       { is: 'rw', lazy: true, init: '' },
      querykey:     { is: 'rw', lazy: true, init: '' },
      resultsCount: { is: 'rw', lazy: true, init: null }

    }
  })
})