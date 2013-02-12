function prepareForExport(){
  prepareOtus();
  prepareMarkers();
  prepareCells();
}

function prepareCells(){
  var container = $('table_body_container')
    , cells     = container.select('td[data-cell-id]').findAll(function(td){return td.down('div.seq_count').innerHTML != ''} );
  cells.each(function (cell) {
    var cell_id         = cell.readAttribute('data-cell-id')
      , ids             = cell.id.split('_')
      , cell_otu_id     = ids[1]
      , cell_marker_id  = ids[2];

    cell.down('div.cell_checkbox').insert({
      bottom: new Element('input', {
                          'type':           'checkbox',
                          'id':             'chk_cell_' + cell_id,
                          'data-cell-id':   cell_id,
                          'data-otu-id':    cell_otu_id,
                          'data-marker-id': cell_marker_id,
                          'class':          'exporting_checkbox'
      })
    })
  })
}

function prepareOtus(){
  var container = $('table_body_container')
    , otuRows   = container.select('tr');

  otuRows.each(function (row){
    var otu_id = row.id.split('_')[1];
    row.down('td').insert({
      bottom: new Element('input', {
                          'type':       'checkbox',
                          'id':         'chk_otu_' + otu_id,
                          'data-otu-id': otu_id,
                          'style':      'float:right;',
                          'class':      'chk_otu exporting_checkbox'
      })
    })
  })
}

function prepareMarkers(){
  var container = $('table_head_container')
    , markerTds = container.select('td.mh');

  markerTds.each(function(td){
    var marker_id = td.id.match(/_([0-9]+)/)[1];
    td.down('div.marker_checkbox').insert({
      bottom: new Element('input', {
                          'type':           'checkbox',
                          'id':             'chk_marker_' + marker_id,
                          'data-marker-id': marker_id,
                          'class':          'chk_marker exporting_checkbox'
      })
    })
  })
}

function CheckboxCell (checkbox){
  //used to instantiate a cell object to find parent cell (marker or otu)
  this.parent = function (type){
    var id = 'chk_' + type + '_' + checkbox.readAttribute('data-' + type + '-id')
    return $(id)
  }
}

function toggleChk(checkbox,chk){
  var checkObj = new CheckboxCell(chk)
    , spouse   = checkbox.id.match(/_([a-zA-Z]+)_/)[1] == 'otu' ? 'marker' : 'otu';
  if ( !checkObj.parent(spouse).checked ){ chk.checked = checkbox.checked ? true : false }
  //only toggles the cell's checkbox if neither of it's parents are checked
  //only need to test spouse's check status because chk.checked tests the other spouse
}

function checkOtherChecks(page, checkbox){
  var type = checkbox.id.match(/_([a-zA-Z]+)_/)[1];
  switch (type){
    case 'otu':
      checkbox.up('tr').select('input[type="checkbox"][data-marker-id]').each(function(chk){ toggleChk(checkbox,chk) })
    break;
    case 'marker':
      $('table_body_container').
        select('input[type="checkbox"][data-marker-id="' + checkbox.readAttribute('data-marker-id') + '"]').
          each(function(chk){ toggleChk(checkbox,chk) })
    break;
    case 'all':
      $(page._id).select('input[type="checkbox"]').each(function(chk){ chk.checked = checkbox.checked ? true : false })
    break;
  }
}