function toggleSearch(element){
  if (element.hasClassName('seq_search_no')){
    element.removeClassName('seq_search_no');
    $$('span.seq_search_yes').first().addClassName('seq_search_no');
    element.addClassName('seq_search_yes');
    $$('span.seq_search_no').first().removeClassName('seq_search_yes');
    $('genbank_seqs').toggle();
    $('tolkin_seqs').toggle();
  }
}