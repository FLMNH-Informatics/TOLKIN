//= require <widgets/templates/tooltip>
//= require <widget>
//= require <matrices>
//= require <molecular/matrix/exporter>
//= require <widgets/matrices/datagrids/observer>
//= require <widgets/matrices/datagrids/cell>
//= require <widgets/matrices/datagrids/cells/focus>

JooseModule('Matrices', function () {
  JooseClass('Datagrid', {
    isa: Widget,
    has: {
      tooltip:          { is: 'rw', init: null  },
      quickEditModeOn:  { is: 'rw', init: false },
      exportModeOn:     { is: 'rw', init: false },
      preExportHTML:    { is: 'rw', init: null  },
      selectedRow:      { is: 'rw', init: null  },
      selectedCol:      { is: 'rw', init: null  },
      type:             { is: 'rw', init: null  },
      cellFocus:        { is: 'rw', lazy: true, init: function () { return new TOLKIN.views.matrix.datagrid.cell.Focus({ context: this.context(), type: this.type(), table: this })}},
      observer:         { is: 'ro', init: function () { return new Matrices.Datagrids.Observer({datagrid: this}); } },
      chrStateDefs:     { is: 'rw' }
    },
    methods: {
      reload: function () {},
      _loadCellElements: function (element) {
        var markerOtuMatch = element.id.match(/^ch?_([0-9]+)_([0-9]+)/);
      },
      syncColumnWidths: function () {
        var matcher = /^(c)_([0-9]+)_([0-9]+)/;
        $$('table_body tr:first td').each( function (element) {
          var matchArray = element.id.match(matcher);
          if (matchArray[2]) {
            element.setStyle({
              width: $('ch_' + matchArray[2]).getWidth() - 6 + 'px'
            })
          }
        })
      },
      setExpanderWidth: function () {},
      hideTooltip: function () {
        if (this.tooltip()) { this.tooltip().hide(); }
      },
      showTooltip: function (tooltipContents, mousePosX, mousePosY) {
        this.setTooltip(new TOLJS.widget.Tooltip({ parent: this, contents: tooltipContents }));
        this.tooltip().show(mousePosX, mousePosY);
      },
      onChange: function () {},
      toggleQuickEditMode: function () {
        if(this._quickEditModeOn == true) {
          $('toggle_quick_edit_mode_link').update('Enter Quick Edit Mode')
          this._quickEditModeOn = false;
          this.context().notifier().success("Quick edit mode off");
          this.highlightNone();
        }else{
          $('toggle_quick_edit_mode_link').update('Exit Quick Edit Mode')
          this._quickEditModeOn = true;
          this.context().notifier().success("Quick edit mode on");
          this.observer().observeForQuickEditMode();
        }
      },
      toggleExportMode: function () {
        this.highlightNone();
        if (this._exportModeOn == true){
          this._exportModeOn = false;
          this.context().notifier().success('Export mode off')
          $$('input.exporting_checkbox').each(function(el){el.remove()})
          $('export_mode_controls').toggle();
//          if(this._preExportHTML){
//            $(this._id).innerHTML = this._preExportHTML
//            $('toggle_export_mode_link').update('Enter Export Mode')
//          }else{
//            window.location.reload()
//          }
        }else{
          $('toggle_export_mode_link').update('Exit Export Mode')
          this._exportModeOn = true;
          this.context().notifier().success('Export mode on.');
//          this.setPreExportHTML($(this._id).innerHTML);
          this.prepareExportMode();
          $('export_mode_controls').toggle();
        }
        $('autofill').toggle();
      },
      prepareExportMode: function () {
        prepareForExport();
      },
      showMouseHover: function(event){
        var gridCell;
        if (event.element().className == "cell_div"){ gridCell = event.element().up('td');}
        else if (event.element().className.startsWith("bt")){ gridCell = event.element();}
        else{gridCell = event.element().up('td');}
        var otuId = gridCell.id.split('_')[1]
          , columnId = gridCell.id.split('_')[2]
          , cellIndex = gridCell.cellIndex
          , rowHeader = $('r_' + otuId).down('td');
        rowHeader.toggleClassName('selected_otu');
        $('ch_' + columnId).toggleClassName('selected_header')
      },
      onMouseover: function(event){
        if (!this._quickEditModeOn){
          Event.delegate({
            '.bt': function(){
              var gridCell;
              if (event.element().className == "cell_div"){ gridCell = event.element().up('td');}
              else if (event.element().className.startsWith("bt")){ gridCell = event.element();}
              else{gridCell = event.element().up('td');}
              if( this._selectedRow && this._selectedCol && $('c_' + this._selectedRow + '_' + this._selectedCol)){
                $('c_' + this._selectedRow + '_' + this._selectedCol).writeAttribute('style','');
                setTableCellWidth(this._selectedRow, this._selectedCol);
              }
              var rowId = gridCell.id.split('_')[1]
                , columnId = gridCell.id.split('_')[2]

              if (this._selectedRow && this._selectedRow != rowId){
                $('rh_' + this._selectedRow).toggleClassName('selected_heading');
                this.setSelectedRow(null);
              }
              if (this._selectedCol && this._selectedCol != columnId){
                $('ch_' + this._selectedCol).toggleClassName('selected_heading')
                this.setSelectedCol(null);
              }
              if (!this._selectedCol){
                $('ch_' + columnId).toggleClassName('selected_heading')
                this.setSelectedCol(columnId)
              }
              if (!this._selectedRow){
                $('rh_' + rowId).toggleClassName('selected_heading')
                this.setSelectedRow(rowId)
              }
              var colorCodes = $('c_' + this._selectedRow + '_' + this._selectedCol).getStyles().backgroundColor.match(/[0-9]+\,\ [0-9]+\,\ [0-9]+/)[0].split(', ')
                , newColorCodes = colorCodes.map(function(code){ return (parseInt(code) + 50).toString(); });
              $('c_' + this._selectedRow + '_' + this._selectedCol).setStyle({backgroundColor: 'rgb(' + newColorCodes.join(', ') + ')'});
            },
            '.mh': function(){this.highlightNone();},
            '.matrix_title': function(){this.highlightNone();}
          }).bind(this)(event)
        }
      },
      onMouseout: function(event){
        if (!this._quickEditModeOn){
          if (event.element() == $('table_body'))           this.highlightNone();
          if (event.element() == $('table_body_container')) this.highlightNone();
          if (event.element() == $('viewport_content_frame_matrices_datagrid')) this.highlightNone();
        }
      },
      highlightNone: function(){
        if( this._selectedRow && this._selectedCol && $('c_' + this._selectedRow + '_' + this._selectedCol)){
          $('c_' + this._selectedRow + '_' + this._selectedCol).writeAttribute('style','');
        }
        if ($('rh_' + this._selectedRow)){
          $('rh_' + this._selectedRow).toggleClassName('selected_heading');
          this.setSelectedRow(null);
        }
        if ($('ch_' + this._selectedCol)){
          $('ch_' + this._selectedCol).toggleClassName('selected_heading')
          this.setSelectedCol(null);
        }
        if (this._cellFocus.unselectElement && this._selectedRow == null && this._selectedCol == null) this._cellFocus.unselectElement(this._cellFocus._selectedElement);
//        if (!this._cellFocus.toString().startsWith('function')) this._cellFocus.unselectElement(this._cellFocus._selectedElement);
      },
      onClick: function (event) {
        Event.delegate({
          '.table_body': function() {
            var ele = Event.findElement(event, 'td');
            if(!this.quickEditModeOn()) {
              //make sure element has been edited before
              if (ele.readAttribute('data-cell-id') != null) {
                this._loadCellElements(ele);
              }
            }
            if (this.quickEditModeOn()) {
              var clickedCell = Event.findElement(event, 'td');
              if(clickedCell) {
                this.cellFocus().selectElement(clickedCell);
              }
            }
          },
          '#toggle_quick_edit_mode_link': function () {
            var me = this;
            if (me.parent().page().iMode()._value == 'edit'){
              me.parent().page().matrixInfo().doIfLastVersion(function(){
                if (me.parent().page().matrixInfo().isLastVersion()) {me.toggleQuickEditMode();} else {me.parent().page().showWrongVersionMessage();}
              }, me.parent().page())
            }else{
              me.parent().page().context().notifier().warn('You must be in Edit mode to complete this action.')
            }

          },
          '#toggle_export_mode_link': function (){
            this.toggleExportMode();
          },
          '#modify_matrix_morphology_link': function () {
            window.location.pathname = this.context().routes().pathFor('modify_matrix_project_morphology_matrix_path');
          },
          'input[type="checkbox"]': function () {
            if (this._exportModeOn == true){
              checkOtherChecks(this, event.element()); //lib/molecular/matrix/exporter.js
            }
          },
          '#toggle_all': function (){
            if (this._exportModeOn == true){
              var chk = event.element().down('input[type="checkbox"]')
                , inner = $('toggle_all').innerHTML;
              chk.checked = chk.checked ? false : true;
              checkOtherChecks(this, chk);
            }
          }
        }).bind(this)(event);
      }
    }
  })
})