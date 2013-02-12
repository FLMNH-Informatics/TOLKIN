function toggleGenbankInputs() {
  $('genbank_inputs').toggleClassName('small_container');
  $('genbank_inputs').toggleClassName('tall_container');
  if ($('toggle_genbank_inputs').innerHTML == '&nbsp;[ - ]'){
    $('toggle_genbank_inputs').innerHTML = '&nbsp;[+]';
  } else {
    $('toggle_genbank_inputs').innerHTML = '&nbsp;[ - ]';
  }
  $('gb_search_options').toggleClassName('unseen');
}

function showLoading(msg){
  $('genbank_results').down('div.catalog-contents').innerHTML = '<img src="/images/ajax-loader-large.gif" alt="' + msg + '"/>';
}

function changeResults(page, tool){

  switch (tool){
      case 'beginning':
        page.setSeqStart(0);
      break;
      case 'end':
        page.setSeqStart(page._resultsCount - page._seqRowLimit);
      break;
      case 'step_back':
        page.setSeqStart((page._seqStart <= page._seqRowLimit) ? 0 : page._seqStart - page._seqRowLimit);
      break;
      case 'step_forward':
        page.setSeqStart((page._seqStart + page._seqRowLimit >= page._resultsCount) ? page._resultsCount - page._seqRowLimit : page._seqStart + page._seqRowLimit)
      break;
  }
  eSearch(page._searchTerm, page)
}

function renderTable(page) {
  var html_to_render = tableHeader(page) + beginTable() + tableRows(page) + endTable() + tableBottom(page);
  $('genbank_results').innerHTML = html_to_render;
}

function sortImg(){
  return '<span class="goright"><img tool="sort" src="/images/sort_incr_13.png" alt="[sort]" /></span>';
}

function th(width){
  return '<th class="trnopoint attribute_name"><div class="posrel" style="width: ' + width + 'px;">';
}

function tableHeader(page){
  var header   = ""
    , columns = page._seqColumns;

  header = header + '<div class="header"><table><tbody><tr class="trnopoint"><th><div><input class="check_all" type="checkbox"></div></th>';
  if (columns.include('Organism'))   header = header + th('128') + 'Organism'   + sortImg() + '</div></th>';
  if (columns.include('Link'))       header = header + th('28')  + 'Link'       +            '</div></th>';
  if (columns.include('Locus'))      header = header + th('78')  + 'Locus'      + sortImg() + '</div></th>';
  if (columns.include('Marker'))     header = header + th('67')  + 'Marker'     + sortImg() + '</div></th>';
  if (columns.include('Definition')) header = header + th('358') + 'Definition' + sortImg() + '</div></th>';
  if (columns.include('Sequence'))   header = header + th('358') + 'Sequence'   + sortImg() + '</div></th>';
  header = header + '</tr></tbody></table></div>';

  return header;
}

function isEven(value){
	if (value%2 == 0){
		return true;
  }else{
		return false;
  }
}

function toggleSeq(page, element) {
  var seqid = parseInt(element.value.toString().split('_')[1])
    , seq   = page._sequences[seqid];
  if (element.checked == 0){
    removeSeq(page, seq);
  } else if (element.checked == 1 && !page._selectedSeqs.include(seq)){
    prepareSeq(page, seq);
  }

  $('tbl_notes_span').innerHTML = page._selectedSeqs.length.toString() + ' sequence(s) selected.  <a tool="unselect_all_seqs" id="unselect_all_seqs">Unselect all</a>';
}

function prepareSeq(page, seq){
  page._selectedSeqs.push(seq);
}

function removeSeq(page, seq){
  page.setSelectedSeqs(page._selectedSeqs.without(seq));
}

function unselectAllSeqs(page){
  if (page._selectedSeqs) page.setSelectedSeqs([]);
  $$('input[type="checkbox"]:not([name="data[]"]):not(.check_all)').each(function(chk){ chk.checked = false });
  $('tbl_notes_span').innerHTML = '';
  if ($('selected_tolkin')){$('selected_tolkin').innerHTML = ''};
  if (page._selectedTolkin) page.setSelectedTolkin([]);
}