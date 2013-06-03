//= require <page>
//= require <html_loader>
//= require <matrices/row_loader>
//= require <molecular/sequences/sequence_exporting>

JooseModule('Molecular.Matrix.Submatrices', function () {
  JooseClass('ShowPage', {
    isa: Page,
    does: [RowLoader, SequenceExporting],
    has: {
      canRender: {is: 'ro', init: false },
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        datagrid: new Matrices.Datagrid({ parent: this.frame(), type: 'molecular' })
      }, this)}}
    },
    methods: {
      onClick: function (event){
        var me = this;

        Event.delegate({
          '#edit_submatrix': function () {
            if (me.iMode()._value == 'edit'){
              me.frame().viewport().widgets().get('window').loadPage('edit_project_molecular_matrix_submatrix_path', {id: params["id"], matrix_id: params["matrix_id"]})
            }else{
              me.notifier().warn('You must be in edit mode to complete this action');
            }
          },
          '#export_selected_seqs': function () {
            var ids = $$('input[type="checkbox"][data-cell-id]:checked').inject('', function (memo,chk){return chk.readAttribute('data-cell-id') + ',' + memo;});
            if (me.iMode()._value == 'edit'){
              if (ids == ""){
                me.msgNoCells();
              }else{
                me.exportSelectedSeqs({cell_ids: ids});
              }
            }else{
              me.notifier().warn('You must be in edit mode to complete this action.')
            }
          },

          '#create_alignment': function () {
            var ids = $$('input[type="checkbox"][data-cell-id]:checked').inject('', function (memo,chk){return chk.readAttribute('data-cell-id') + ',' + memo;});
            if (me.iMode()._value == 'edit'){
              if (ids == ""){
                me.msgNoCells();
              }else{
                me.createAlignment({cell_ids: ids});
              }
            }else{
              me.notifier().warn('You must be in edit mode to complete this action.')
            }
          },

          '.sub_move': function () {
            var moveType = event.element().classNames().detect(function(className){return className.startsWith('move_')})
              , itemType = event.element().up('div').up('div').className.split('_')[1]
              , itemId   = event.element().up('td').id.split('_').last();
            this.tryMoveItem({type: itemType, move: moveType, item_id: itemId})

          }
        }).call(this,event)
      },

      tryMoveItem: function (requestParams) {
        var me = this;
        this.notifier().working('Moving ' + (requestParams["type"] == 'otu' ? 'OTU' : requestParams["type"]) + "...")
        new Ajax.Request(this.context().routes().pathFor('change_position_project_molecular_matrix_submatrix_path'),{
          method: 'post',
          parameters: requestParams,
          onSuccess: function (response){
            if (response.responseJSON && response.responseJSON.error){
              me.notifier().error(response.responseJSON.error.toString())
            }else{
              if (!response.responseJSON) me.moveItem(requestParams);
              me.notifier().success(requestParams["type"].capitalize() + " successfully moved.");
            }
          },
          onFailure: function (){
           me.notifier().error('Something went wrong.');
          }
        })
      },

      moveItem: function(moveInfo){
        var move = moveInfo['move']
          , type = moveInfo['type']
          , itemId = moveInfo['item_id'];

        if (type == 'otu'){
          var row = $('r_' + itemId)
          this.moveRow(row,move)
        }else if (type == "marker"){
          this.moveColumn(itemId, move)
        }
      },

      moveRow: function (row, move){
        var newRow = row.clone(true);
        switch (move){
          case 'move_to_top':     $('table_body').down('tr').insert({before: newRow});         break;
          case 'move_to_bottom':  $('table_body').select('tr').last().insert({after: newRow}); break;
          case 'move_higher':     if (row.previous()) row.previous().insert({before: newRow}); break;
          case 'move_lower':      if (row.next()) row.next().insert({after: newRow});          break;
        }
        row.remove();
      },

      moveColumn: function (id, move){
        var newHeader = $('ch_'+ id).remove().clone('true')
          , columnNumber = parseInt(newHeader.readAttribute('col'))
          , cells  = $('table_body').select('tr').map(function(row){
            return row.select('td')[columnNumber].remove().clone('true')
          })
          , headers = $('table_head_container').select('td.mh');
        switch(move){
          case 'move_to_top':
            headers.first().insert({before: newHeader});
            headers.each(function(header){
              if (header.hasAttribute('col')){
                if (parseInt(header.readAttribute('col')) < columnNumber){
                  header.writeAttribute({'col': (parseInt(header.readAttribute('col')) + 1).toString() });
                }
              }
            })
            newHeader.writeAttribute({'col': "1"});
            $('table_body').select('tr').each(function(row,index){
              var cell = cells[index];
              row.select('td')[1].insert({before: cell})
            })
            break;
          case 'move_to_bottom':
            headers.last().insert({after: newHeader});
            newHeader.writeAttribute({'col': (headers.length + 1).toString()})
            headers.each(function(header){
              if (header.hasAttribute('col')){
                if (parseInt(header.readAttribute('col')) > columnNumber){
                  header.writeAttribute({'col': (parseInt(header.readAttribute('col')) -1 ).toString()});
                }
              }
            })
            $('table_body').select('tr').each(function(row,index){
              var cell = cells[index];
              row.select('td').last().insert({after: cell});
            })
            break;
          case 'move_higher':
            var col = $('table_head_container').select('td.mh')[columnNumber - 2];
            col.insert({before: newHeader});
            col.writeAttribute({'col': columnNumber.toString()});
            newHeader.writeAttribute({'col': (columnNumber - 1).toString() })
            $('table_body').select('tr').each(function(row,index){
              var cell = cells[index];
              row.select('td')[columnNumber -1].insert({before: cell})
            })
            break;
          case 'move_lower':
            var col = $('table_head_container').select('td.mh')[columnNumber - 1];
            col.insert({after: newHeader});
            col.writeAttribute({'col': columnNumber.toString()});
            newHeader.writeAttribute({'col': (columnNumber + 1)})
            $('table_body').select('tr').each(function(row,index){
              var cell = cells[index];
              row.select('td')[columnNumber].insert({after: cell})
            })
            break;
        }
      }
    }
  })
})