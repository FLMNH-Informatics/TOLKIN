//= require <matrices/matrix_type>
JooseRole('RowLoader', {
  does: MatrixType,
  has: {
    currentlyLoading: {is: 'rw', init: false }
  },
  after: {
    initialize: function () {
      this.showMatrixLoading();
    },
    onLoad: function () {
      this.loadMatrixRows();
    }
  },
  methods: {
    _datagridTableHead: function () { return $(this._widgets.get('datagrid').id()).down('table'); },

    _datagridTable:     function () { return $("table_body"); },

    _datagridTableBody: function () { return $("table_body").down('tbody'); },

    showMatrixLoading: function (){
      var datagridWidth = this._datagridTableHead().getWidth()
        , rowLoadingGif = new Element('div', {'class': 'row_loading', 'style': 'width: '+ (datagridWidth - 2).toString() + 'px'});
      if ($('table_empty_message').innerHTML.strip() == ""){
        this._datagridTable().insert({'after': rowLoadingGif.update("<img src='/images/seq-dna-loading.gif' alt='Loading...'/>")})
      }
      $('table_body_container').setStyle({'width': (datagridWidth+ 15) + 'px'}).down('div.table_body_expander').setStyle({'width': (datagridWidth) + 'px'})
    },

    loadMatrixRows: function () {
      var me = this
        , yIds = $$('.mh').map(function(td){ return me._type() == "morphology" ? td.dataset.characterId : td.dataset.markerId;})
        , matricesOtus = matrices_otus
        , otusIndex = 0;

      function getRow(motu){
        me.setCurrentlyLoading(true)
        var type = me.meta._name.split('.').reverse()[1];
        var m_otus = motu.matrices_otus || motu.submatrix_otus;
//        new Ajax.Request(me.context().routes().pathFor('load_row_project_' + me._type() + '_matrix_path'),{
        new Ajax.Request('/projects/'+ params["project_id"] + "/" + me._type() + "/matrices/" + params["matrix_id"] + "/load_row",{
          method:     'GET',
          parameters: {
            'matrix_otu_id': m_otus.id,
            'otu_id':        m_otus.otu_id,
            'position':      m_otus.position || (matricesOtus.indexOf(motu) + 1),
            'page':          params['page'],
            'y_ids[]':       yIds,
            'date':          params['date'],
            "type":          type
          },
          onSuccess:  function(response){
            if (otusIndex == 0){
              me._datagridTableBody().insert({'bottom': response.responseJSON.row}); //see note below
              $$('.just_loaded').each(function(cell){
                var otu_id = cell.id.split('_')[1]
                  , y_id = cell.id.split('_')[2];
                setTableCellWidth(otu_id,y_id);
                cell.removeClassName('just_loaded');})
            }else{
              //had to do it like this because inserting at bottom of tbody resulted in one tbody for each new row
              if (!me._datagridTable().select('tr').empty()){
                if (response.responseJSON){
                  me.insertRow(response.responseJSON.row)
                }
              }else{
                alert('NO TRS.  otuIndex should be 0 but is instead ' + otusIndex.toString())
              }
            }
            if (++otusIndex < matricesOtus.length && me._currentlyLoading){
              getRow(matricesOtus[otusIndex]);
            }else{
              $$('.row_loading').first().remove();
              me.setCurrentlyLoading(false);
            }
          },
          onFailure:  function(){}
        });
      }

      if (!matricesOtus.empty()) getRow(matricesOtus[otusIndex]);
    },
    insertRow: function (row){
      var datagrid = this.widgets().get('datagrid')
        , newRow = this._datagridTable().select('tr').last().insert({'after': row}).next();
      if (datagrid._exportModeOn){
        var cells = newRow.select('td[data-cell-id]').findAll(function(td){return td.down('div.seq_count').innerHTML != ''});
        datagrid.prepareSingleOtuRow(newRow);
        cells.each(function(cell){datagrid.addCheckboxToCell(cell)});
      }
      if (datagrid._submatrixModeOn){
        datagrid.prepareSingleOtuRow(newRow);
      }
      if (datagrid._moveModeOn){
        newRow.down('.move_otu').toggle();
      }
    }
  }
})