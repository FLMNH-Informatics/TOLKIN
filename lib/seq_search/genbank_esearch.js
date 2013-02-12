function eSearch(term, page, notify, options){
  var seqs
    , me       = page
    , fullterm = term.include('[') ? term : makeQuery().join('+')
    , start    = page._seqStart
    , container = $('genbank_results')
    , extra_options;
  function makeQuery(){
    var genbankQuery = [];
    if (term != "") {
      genbankQuery.push(term + "[ALL]");
    }
    if (!$('genbank_org_field').value.blank()) {
      genbankQuery.push($('genbank_org_field').value.toLowerCase().gsub(/\s+/, '+') + '[Organism]');
    }
    if (!$('genbank_gene_field').value.blank()) {
      genbankQuery.push($('genbank_gene_field').value.toLowerCase().gsub(/\s+/, '+') + '[Gene]');
    }
    return genbankQuery;
  }
  if (fullterm != ""){
    if (!options) {
      extra_options = '';
    } else {
      extra_options = options;
    }

    if (!term.include('[')){
      unselectAllSeqs(me);
      $('genbank_results').innerHTML = '';
    } else {
      container.down('div.catalog-contents').setStyle({height:  $('genbank_results').down('div.catalog-contents').getHeight().toString() + 'px'});
      container.down('div.catalog-contents').innerHTML = '<div style="height: 100%; text-align: center; position: relative; top: 50%;"><img src="/images/ajax-loader-large-alt.gif" alt="Gathering more results"></div>';
      container.down('div.border').innerHTML = '<img height="10px" src="/images/seq-dna-loading.gif" alt="Gathering more results">';
    }
    if (notify != 'no' ) {
      page.notifier().working('Contacting Genbank...');
    }
    if ($('esearch')) $('esearch').toggleClassName('esearch');
    if ($('esearch')) $('esearch').toggleClassName('btn_loading');
  //  if ($('add_genbank_seq')){ if ($('add_genbank_seq').getStyle('display') == 'inline'){ $('add_genbank_seq').toggle() } }
  //maybe load ajax-loader here in div

    new Ajax.Request('/projects/' + params['project_id'] + '/molecular/sequences/search_nucleotide', {
      method: 'get',
      parameters: { columns: me._seqColumns.join(','), term: fullterm, retmax: me._seqRowLimit, retstart: start, querykey: me._querykey, webenv: me._webenv, count: me._resultsCount },
      onSuccess: function (response) {
        if (!response.responseJSON.errormsg){
          var btnAddGB = $('add_genbank_seq');
          if (btnAddGB && me.iMode()._value == 'edit' && btnAddGB.getStyle('display') == 'none'){
            $('add_genbank_seq').toggle();
          }
          if ($('genbank_results')){$('genbank_results').innerHTML = response.responseJSON.table_header + response.responseJSON.table;}
          if ($('cell_left') && $('cell_left').getHeight() < $('cell_right').getHeight()){
            $('cell_left').style.height = $('cell_right').getHeight().toString() + 'px';
          }
          var r = response.responseJSON;
          seqs = r.seqs;
          if (notify != 'no') {
            me.notifier().success('Showing results ' + (me._seqStart + 1).toString() + ' through ' + (me._seqStart + me._seqRowLimit).toString() + ' of ' + r.count.toString() + ' result(s).');
          }
          me.setSequences(seqs);
          me.setResultsCount(r.count);
          me.setQuerykey(r.history.querykey);
          me.setWebenv(r.history.webenv);
          me.setSearchTerm(fullterm);
        } else {
          var msg = 'Genbank Error(s) - ' + response.responseJSON.errormsg;
          if ($('genbank_results')) $('genbank_results').innerHTML = msg;
          me.notifier().warning(msg);
        }
      },
      onFailure:  function (response) { me.notifier().error('Something went wrong fetching Genbank results'); },
      onComplete: function (response) {
        if ($('esearch')) {
          $('esearch').toggleClassName('btn_loading');
          $('esearch').toggleClassName('esearch');
        }
      }
    })
  }else{ me.notifier().warning('You must enter a search term'); }
}