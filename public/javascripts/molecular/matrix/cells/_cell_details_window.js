$('search_genbank_link').observe('click', function(e) {
  new Ajax.Request("/projects/" + params['project_id'] + "/mol_matrices/" + params['mol_matrix_id'] + "/cells/" + params['id'] + "/show_search_genbank", {
    method: 'get'
  });
});


