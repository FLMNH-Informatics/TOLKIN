//= require <page>
//= require <molecular/insd/seq>
//= require <molecular/new_mol_marker>

JooseModule('Molecular.FastaFilenames', function (){
  JooseClass('ShowPage', {
    isa: Page,
    has: {
      title:          { is: 'ro', init: 'List of sequences'},
      savable:        { is: 'ro', init: true },
      canRender:      { is: 'ro', init: false },
      htmlLoader:     { is: 'ro', lazy: true, init: function (){
        return $HtmlLoader({ pathname: 'project_molecular_fasta_filename_path'}, this)
      }}
    },
    after: {
      onLoad: function () {this.notifier().success('Received sequences.')}
    },
    methods:  {}
  })
})