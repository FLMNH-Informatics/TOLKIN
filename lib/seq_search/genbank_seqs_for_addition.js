function msgAddToTolkin(page){
  $('seqs_for_addition_message').innerHTML = 'Ready to add ' + (page._sequences.length - page._dontsave.length).toString() + ' sequence(s) to Tolkin.  ';
}

function displayGenbankSeqs(page){
  if (page.meta._name == "Molecular.Matrix.Cells.ShowCellPage" || page.meta._name == "Molecular.Matrix.Cells.ShowCellPage" || page.meta._name == "Molecular.Matrix.Cells.NewPage"){
    return renderGenbankSeqsForMatrixCell(page).join('');
  }else{
    msgAddToTolkin(page);
    return renderGenbankSeqsForTolkin(page);
  }
}

function renderGenbankSeqsForMatrixCell(page){
  var classcounter = $('cell_sequences_list').childElements().last() ?
                      ($('cell_sequences_list').childElements().last().hasClassName('body-odd') ? 2 : 1)
                      : 1;
  return page._selectedSeqs.collect(function (seq) {
    var html      = ''
      , index     = page._sequences.indexOf(seq).toString()
      , marker    = seq.marker ? (seq.marker.marker ? (seq.marker.marker.name) : (seq.marker.name) ) : 'unknown'
      , organism  = seq.organism
      , locus     = seq.locus
      , classname     = classcounter%2 == 0 ? 'body-even' : 'body-odd';

    if (!page._seqsToAdd.include(seq)){
      page._seqsToAdd.push(seq)
      html = html + '<tr class="' + classname + '" id="gb_seq_row_' + index + '"  gb_index_id="' + index + '">' +
        '<td class="b tdseq"><input type="checkbox" id="gb_sequence_' + index + '" name="gb_sequences[]" value="gb_' + index + '" /></td>' +
        '<td class="b tdseq tdcenter"><a target="_blank" href="http://www.ncbi.nlm.nih.gov/nuccore/' + locus + '"><img src="/images/genbank.gif" alt="genbank_link"></a></td>' +
        '<td class="b tdseq">' + organism + '</td>' +
        '<td class="b tdseq tdcenter">' + marker + '</td>' +
        '</tr>';
    }
    classcounter = classcounter + 1;
    return html;
  })
}

function renderGenbankSeqsForTolkin(page){
  return page._sequences.collect(function (seq) {
    var html = '';
    html = html + '<tr class="seq_row" id="seq_' + page._sequences.indexOf(seq) + '">';
    if (page._dontsave.indexOf(seq) == -1){
      html = html + '<td class="exclude_seq"><a class="remove_seq"><img src="/images/16-em-cross.png" alt="don\'t save" /></a></td>';
      html = html + '<td>';
      html = html + '<div class="seq_org">' + seq.organism + '</div>';
      html = html + '<div class="seq_definition indent">' + seq.definition + '</div>';
      html = html + '<div class="seq_seq indent">' + seq.sequence + '</div>';
      html = html + '<div class="seq_marker indent">';
      if (seq.markers) {
        html = html + 'Markers:<table><tr>';
        seq.markers.each( function (marker) {
          html = html + '<td><div>Type: </div>';
          html = html + '<div>Name: </div>';
          html = html + '<div>Start position: </div>';
          html = html + '<div>End position: </div></td>';
          html = html + '<td><div>' + marker.type + '</div>';
          html = html + '<div>' + marker.name + '</div>';
          html = html + '<div>' + marker.start_position + '</div>';
          html = html + '<div>' + marker.end_position + '</div></td>'; } )
          html = html + '</tr></table>';
      }
      html = html + '</div>';
    }else{
      html = html + '<td><a class="undo_remove" id="useseq_' + page._sequences.indexOf(seq) +'">' +
        '<img id="plusimageseq_' + page._sequences.indexOf(seq) + '" src="/images/plus.png" alt="do save" /></a></td>' +
        '<td><div id="rem_seq_cont_'+ page._sequences.indexOf(seq) + '">' +
        'Sequence Removed (<a class="undo_remove" id="undo_' + page._sequences.indexOf(seq) + '">undo</a>)' +
        '</div></td>';
    }
    html = html + '</td></tr>';

    return html;
  })
}