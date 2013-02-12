$('esearch_nucleotide_form').observe('submit', function(e) {
  e.stop();
  new Ajax.Request("/projects/" + params['project_id'] + "/molecular/matrices/" + params['matrix_id'] + "/cells/" + params['id'] + "/search_genbank",
  {
    parameters : { 
      search_query: $F($('esearch_nucleotide_form')['search_query'])
    },
    requestHeaders : [ "Accept", "application/json" ],
    method : 'get',
    onSuccess : function(transport) {
      display = "<table>"
      alert(transport.responseText);
      var summaries = eval(transport.responseText);
      if(summaries.size() > 0) {
        summaries.each(function(summary)
        {
          display += "<tr valign='top'><td><input type='checkbox' name='gi[" + summary.gi + "]' /></td><td>Identifier:</td><td>" + summary.extra + "</td></tr>\n" +
          "<tr valign='top'><td></td><td>Description:</td><td>" + summary.title + "</td></tr>\n" +
          "<tr valign='top'><td></td><td>Length:</td><td>" + summary.length + "</td></tr>\n" +
          "<tr valign='top'><td></td><td>Create Date:</td><td>" + summary.create_date + "</td></tr>\n" +
          "<tr valign='top'><td></td><td>Update Date:</td><td>" + summary.update_date + "</td></tr>\n" +
          "<tr><td style='height: 10px;'></td></tr>";
        });
        display += "</table>"
      } else {
        display = "No results found."
      }
      $('genbank_search_results').update(display);
    }
  });
});  


