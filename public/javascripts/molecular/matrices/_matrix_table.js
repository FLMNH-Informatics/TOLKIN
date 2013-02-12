function a(otu_id, marker_id) {
  new Ajax.Request(
    '/projects/' + params['project_id'] + '/molecular/matrices/' + (params['matrix_id'] || params['id']) + '/cells/' + marker_id + "-" + otu_id ,
    {
      method:'get',
      parameters:'authenticity_token=' + AUTH_TOKEN
    }
    );
}

function requestCellDetailsWithId(cell_id) {
  new Ajax.Request(
    '/projects/' + params['project_id'] + '/molecular/matrices/' + (params['matrix_id'] || params['id']) + '/cells/' + cell_id ,
    {
      method:'get',
      parameters:'authenticity_token=' + AUTH_TOKEN
    }
    );
}

Event.observe('table_body','click',function(event) {
  var ele = Event.findElement(event, 'td');
  var cell_id = ele.readAttribute('cell_id');
  if(cell_id) {
    requestCellDetailsWithId(cell_id);
  } else {
    var reg = /^(ch?)_([0-9]+)_([0-9]+)(_([0-9]+))?/;
    var resArr = reg.exec(ele.id);
    a(resArr[2], resArr[3]);
  }
});

