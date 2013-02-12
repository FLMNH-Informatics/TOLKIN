//= <require <templates/auto_text_field>

JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('TaxonNameAutoTextField', {
    isa: Templates.AutoTextField,
    has: {
      object:         { is: 'ro', init: 'molecular_insd_seq' },
      method:         { is: 'ro', init: 'taxon' },
      collectionURI:  { is: 'ro', init: 'project_taxa_path' },
      valueMethod:    { is: 'ro', init: 'taxon_id' },
      textMethod:     { is: 'ro', init: 'name' },
      searchMethod:   { is: 'ro', init: 'name' },
      width:          { is: 'ro', init: 275 },
      objectName:     { is: 'ro', init: 'taxon' },
      options:        { is: 'ro', init: function() { return ({
        parameters:   { select: 'taxon_id, name' }
      })}}
    }
  })
});