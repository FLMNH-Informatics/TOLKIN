Module('TOLKIN.views.matrix.datagrid', function () {
  JooseClass('_Cell', {
    has: {
      element: {is: 'ro', required: true, nullable: false},
      chrStates: {is: 'ro', required: true, nullable: false},
      status: {is: 'rw', lazy: true, init: function () {
          switch(this.element().getStyle('background-color')) {
            case 'rgb(255, 255, 153)' :return 'incomplete';
            case 'rgb(153, 255, 255)' :return 'complete';
            case 'rgb(255, 136, 136)' :return 'problem';
          }
      }},
      context:         {is: 'ro', required: true, nullable: false},
      initStatus:      {is: 'ro'},
      initInnerHTML:   {is: 'ro'},
      initStatesArray: {is: 'ro', lazy: true, init: function() {return this.element().innerHTML.split(' ')}},
      isModified:      {is: 'ro', init: false},
      id:              {is: 'ro', lazy: true, init: function () {return this.element().readAttribute('data-cell-id')}},
      matcher:         {is: 'ro', init: function () { return /^(c)_([0-9]+)_([0-9]+)/ }},
      matchArray:      {is: 'ro', lazy: true, init: function () {return this.matcher().exec(this.element().id)}},
      statesArray:     {is: 'ro', init: function () {return []}},
      otu_id:          {is: 'ro', lazy: true, init: function () {return this.matchArray()[2]}},
      character_id:    {is: 'ro', lazy: true, init: function () {return this.matchArray()[3]}}
    },
    after: {
      initialize: function () {
        var cell = this;
        this._initStatus = this.status();
        this._initInnerHTML = this.element().innerHTML;
        this.initStatesArray().each(function(state) {
          cell.statesArray().push(state);
        });
        this._initStatesArray = this.statesArray().clone();
      }
    },
    methods: {
      updateInitialValues: function() {
        this._initInnerHTML = this.element().innerHTML;
        this._initStatus = this.status();
      },

      isModified: function() {
        return this._isModified;
        this._initStatus = this.status();
        this._initStatesArray = this.statesArray().clone();
      },

      save: function() {
        var uri, method;
        var parameters = "cell[status]=" + this.status() + "&" +
          "cell[state_codings]=" + this.statesArray().compact().sort().join(" ").sub('?', '%3F'); //need sub to encode the question mark
        if(this.id()) {
          uri = '/projects/' + params['project_id'] + '/morphology/matrices/' + params['matrix_id'] + '/cells/' + this.id();
          method = 'put';
        } else {
          uri = '/projects/' + params['project_id'] + '/morphology/matrices/' + params['matrix_id'] + '/cells';
          method = 'post';
          parameters += '&' + 'cell[character_id]=' + this.character_id() + '&' +
            'cell[otu_id]=' + this.otu_id();
        }
        var cell = this;
        new Ajax.Request(uri, {
          method: method,
          parameters : parameters,
          onSuccess: function(transport) {
            var result = transport.responseText.evalJSON();
            cell.element().writeAttribute('data-cell-id', result.cell.data_cell_id);
            cell.updateInitialValues();
            cell.context().notifier().success('Cell successfully saved.');
          },
          onFailure: function(transport) {
            $('notice').update(transport.responseText);
            this.element().innerHTML = 'ERROR';
          }
        });
      },

      setStatus: function(statusStr) {
        this._status = statusStr;
        if(this._status == 'complete') {
          this.element().writeAttribute('class', 'bt b');
          this.element().setStyle('background-color: #9FF;');
        } else if(this._status == 'incomplete') {
          this.element().writeAttribute('class', 'bt a');
          this.element().setStyle('background-color: #FF9;');
        } else if(this._status == 'problem') {
          this.element().writeAttribute('class', 'bt c');
          this.element().setStyle('background-color: #F88;');
        }
        this._isModified = true;
      },

      toggleState: function(stateSymbol) {
        // if symbol is valid
        if(stateSymbol.match(/[\-\?]/) || this.chrStates()[stateSymbol]) { // only toggle character states if they are defined
          var index;
          // if symbol is dash or question mark
          if(stateSymbol.match(/[\?\-]/)) {
            if(stateSymbol.match(/\-/)) {
              this._statesArray = [ ];
            } else {
              // if there is already a dash or question mark remove it, otherwise set dash or question mark as the only coding
              (this.statesArray()[0] == stateSymbol) ? this.statesArray()[0] = null : this._statesArray = [ stateSymbol ];
            }
          // if symbol is a numeral
          } else {
            // if coding is currently set to a dash or question mark
            if(this.statesArray()[0] && this.statesArray()[0].match(/[\-\?]/)) {
              // replace that dash or question mark with the new coding
              this.statesArray()[0] = stateSymbol;
            // if coding is numeric or empty
            } else {
              // if current symbol is already coded
              if ((index = this.statesArray().indexOf(stateSymbol)) >= 0) {
                // remove that symbol
                this.statesArray()[index] = null;
              // current symbol is not coded
              } else {
                // add that symbol to coding
                this.statesArray().push(stateSymbol);
              }
            }
          }
          var outStr = this.statesArray().compact().sort().join(" ");
          this.element().innerHTML = ( outStr == "" ) ? "----" : outStr;
          this._isModified = true;
        }
      },

      revert: function() {
        this.element().innerHTML = this.initInnerHTML();
        this.setStatus(this.initStatus());
        this._statesArray = this.initStatesArray().clone();
        this._isModified = false;
      }
    }
  })
});