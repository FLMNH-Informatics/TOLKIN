//= require <widgets/templates/outlinks_table>

Module('Taxa', function() {
  JooseClass('TaxonOutlinksTable', {
    isa: Templates.OutlinksTable
  })
});
