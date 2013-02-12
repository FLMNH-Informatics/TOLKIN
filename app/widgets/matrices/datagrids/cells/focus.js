//= require "../cell"

JooseModule('TOLKIN.views.matrix.datagrid.cell', function() {
  JooseClass('Focus', {
    has: {
      context: { is: 'ro', required: true, nullable: false },
      selectedElement: {init: null},
      selectedCell: {is: 'rw', init: null},
      table: {is: 'ro', required: true, nullable: false},
      type: {is: 'ro', required: true, nullable: false}
    },
    methods: {
      goDown: function() {
        var colNumber = parseInt(this._getSelectedColumnNumber());
        var nextRow = this._selectedElement.up().next();
        var cell = nextRow ? nextRow.down("td:nth-child(" + (colNumber + 1) + ")") : null;
        this.goToCell(cell);
      },

      goLeft: function() {
        var cell = this._selectedElement.previous();
        this.goToCell(cell);
      },

      goRight: function() {
        var cell = this._selectedElement.next();
        this.goToCell(cell);
      },

      goToCell: function(cell) {
        if(cell && cell.id.startsWith('c')) {
          this.selectElement(cell)
        }
      },

      goUp: function() {
        var colNumber = parseInt(this._getSelectedColumnNumber());
        var prevRow = this._selectedElement.up().previous();
        var cell = prevRow ? prevRow.down("td:nth-child(" + (colNumber + 1) + ")") : null;
        this.goToCell(cell);
      },

      showCellDetails: function() {
        this.selectedCell().showDetails();
      },

      selectElement: function(element) {
        if(this._selectedElement) {
          this._unhighlightElement(this._selectedElement)
        }
        if(this.table().quickEditModeOn() && this.selectedCell() && this.selectedCell().isModified()) { // save any cell changes to db before moving to a new cell
          this.selectedCell().save();
        }
        this._highlightElement(element);
        this._selectedElement = element;

        switch(this.type()) {
          case 'morphology':
            var cellChrStates = this.table().chrStateDefs()[this._getSelectedColumnId()] || [ ];
            this._selectedCell = new TOLKIN.views.matrix.datagrid._Cell({ context: this.context(), element: element, chrStates: cellChrStates});
            this.displayStatesForQuickEditMode(cellChrStates);
            break;
        }
      },

      displayStatesForQuickEditMode: function(states){
        var display = ''
        if (!states.empty()) states.each(function(state,index){ display += "<li>" + index + " : " + state + "</li>"; })
        $('state_display_list').innerHTML = display;
      },

      unselectElement: function() {
        this.selectedCell() && this.selectedCell().revert();
        this._selectedElement && this._unhighlightElement(this._selectedElement);
      },

      _getSelectedColumnId: function() {
        var matcher = /^(c)_([0-9]+)_([0-9]+)/;
        var matchArray = matcher.exec(this._selectedElement.id);
        return matchArray[3];
      },

      _getSelectedColumnNumber: function() {
        if(/ch/.exec(this._selectedElement.id)) {
          return 0;
        } else {
          var charId = this._getSelectedColumnId();
          return $('ch_' + charId).readAttribute('col');
        }
      },
      _toggleHeadings: function(cell){
        var rowId = cell.id.split('_')[1]
          , columnId = cell.id.split('_')[2];
        $('rh_' + rowId).toggleClassName('selected_heading');
        $('ch_' + columnId).toggleClassName('selected_heading');
      },
      _unselectHeadings: function(cell){
        var rowId = cell.id.split('_')[1]
          , columnId = cell.id.split('_')[2];
        $('rh_' + rowId).removeClassName('selected_heading');
        $('ch_' + columnId).removeClassName('selected_heading');
      },
      _highlightElement: function(cell) {
        this._toggleHeadings(cell);
        switch(cell.getStyle('background-color')) {
          case 'rgb(78, 78, 78)' :
            cell.setStyle('background-color: #777;');
            break;
          case 'rgb(253, 233, 129)' :
            cell.setStyle('background-color: #FF9;');
            break;
          case 'rgb(155, 230, 253)' :
            cell.setStyle('background-color: #9FF;');
            break;
          case 'rgb(254, 79, 79)' :
            cell.setStyle('background-color: #F88;');
            break;
          case 'rgb(238, 187, 238)': // purple: #ebe
            cell.setStyle('background-color: #f5d6f5');
            break;
          case 'rgb(17, 221, 119)': // green: #1d7
            cell.setStyle('background-color: #42f099');
            break;
          case 'rgb(255, 187, 34)': // orange: #fb2
            cell.setStyle('background-color: #ffd066');
        }
      },

      _unhighlightElement: function(cell) {
        cell.style.backgroundColor = '';
        this._unselectHeadings(cell);
      }
    }
  })
});

