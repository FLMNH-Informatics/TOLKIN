JooseRole('DatagridSelector', {
  methods: {
    prepareForExport: function () {
      this.prepareOtus();
      this.prepareMarkers();
      this.prepareCells();
    },

    prepareForSubmatrix: function () {
      this.prepareMarkers();
      this.prepareOtus();
    },

    addCheckboxToCell: function (cell) {
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
                            'class':          'selecting_checkbox'
        })
      })
    },

    prepareCells: function () {
      var container = $('table_body_container')
        , cells     = container.select('td[data-cell-id]').findAll(function(td){return td.down('div.seq_count').innerHTML != ''} )
        , me        = this;

      cells.each(function(cell){me.addCheckboxToCell(cell);})
    },

    prepareOtus: function () {
      var container = $('table_body_container')
        , otuRows   = container.select('tr')
        , me        = this;

      otuRows.each(function (row){
        me.prepareSingleOtuRow(row);
      })
    },

    prepareSingleOtuRow: function (row) {
      var otu_id = row.id.split('_')[1];
      row.down('td').insert({
       top: new Element('input', {
                           'type':       'checkbox',
                           'id':         'chk_otu_' + otu_id,
                           'data-otu-id': otu_id,
                           'data-motu-id': row.down('td').dataset.motuId,
                           'style':      'float:right;',
                           'class':      'chk_otu selecting_checkbox'
       })
      })
    },

    prepareMarkers: function (){
      var container = $('table_head_container')
        , markerTds = container.select('td.mh');

      markerTds.each(function(td){
        var marker_id = td.id.match(/_([0-9]+)/)[1];
        td.down('div.marker_checkbox').insert({
          bottom: new Element('input', {
                              'type':                  'checkbox',
                              'id':                    'chk_marker_' + marker_id,
                              'data-marker-id':        marker_id,
                              'data-matrix-marker-id': td.dataset.matrixMarkerId,
                              'class':                 'chk_marker selecting_checkbox'
          })
        })
      })
    },

    toggleChk: function (checkbox,chk){
      function CheckboxCell (checkbox){
        //used to instantiate a cell object to find parent cell (marker or otu)
        this.parent = function (type){
          var id = 'chk_' + type + '_' + checkbox.readAttribute('data-' + type + '-id')
          return $(id)
        }
      }
      var checkObj = new CheckboxCell(chk)
        , spouse   = checkbox.id.match(/_([a-zA-Z]+)_/)[1] == 'otu' ? 'marker' : 'otu';
      if ( !checkObj.parent(spouse).checked ){ chk.checked = checkbox.checked ? true : false }
      //only toggles the cell's checkbox if neither of it's parents are checked
      //only need to test spouse's check status because chk.checked tests the other spouse
    },

    checkOtherChecks: function (page,checkbox){
      var type = checkbox.id.match(/_([a-zA-Z]+)_/)[1]
        , me = this;
      switch (type){
        case 'otu':
          checkbox.up('tr').select('input[type="checkbox"][data-marker-id]').each(function(chk){ me.toggleChk(checkbox,chk) })
        break;
        case 'marker':
          $('table_body_container').
            select('input[type="checkbox"][data-marker-id="' + checkbox.readAttribute('data-marker-id') + '"]').
              each(function(chk){ me.toggleChk(checkbox,chk) })
        break;
        case 'all':
          $(page._id).select('input[type="checkbox"]').each(function(chk){
            if (!chk.id.startsWith('toggle')) chk.checked = checkbox.checked ? true : false
          })
        break;
        case 'otus':
          $$('.chk_otu').each(function(chk){chk.checked = checkbox.checked ? true : false })
        break;
        case 'markers':
          $$('.marker_checkbox').each(function(mc){mc.down('input[type="checkbox"]').checked = checkbox.checked ? true : false })
        break
      }
    }
  }
})