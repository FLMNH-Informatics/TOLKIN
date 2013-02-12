function Notifier() {
  this.notice = function(message) {
    $('notice').update(message);
  }
}
Notifier.prototype = (function() {
  return {
    constructor: Notifier
  };
})();

function MorphologyCell(element, chrStates) {
  var status;

  switch(element.getStyle('background-color')) {
    case 'rgb(255, 255, 153)' :
      status = 'incomplete';
      break;
    case 'rgb(153, 255, 255)' :
      status = 'complete';
      break;
    case 'rgb(255, 136, 136)' :
      status = 'problem';
  }
  var initStatus = status;
  var initInnerHTML = element.innerHTML;

  var isModified = false;

  var matcher = /^(c)_([0-9]+)_([0-9]+)/;
  var matchArray = matcher.exec(element.id);

  var initStatesArray = element.innerHTML.split(" ");
  var statesArray = [ ];
  chrStates.each(function(state, index) {
    statesArray[index] = null
  });
  initStatesArray.each(function(state) {
    statesArray[parseInt(state)] = state;
  });
  initStatesArray = statesArray.clone();

  var updateInitialValues = function() {
    initInnerHTML = element.innerHTML;
    initStatesArray = statesArray.clone();
    initStatus = status;
  }

  this.otu_id = matchArray[2];
  this.character_id = matchArray[3];

  this.isModified = function() {
    return isModified;
    var initStatus = status;
    initStatesArray = statesArray.clone();
  }

  this.save = function() {
    new Ajax.Request('/projects/' + params['project_id'] + '/matrices/' + params['id'] + '/update_state_codings/' + this.otu_id + "/" + this.character_id, {
      parameters : {
        'cell[status]' : status,
        'cell[codings]' : statesArray.compact().join(" ")
      },
      onSuccess: function(transport) {
        $('changes_list').replace(transport.responseText);
        updateInitialValues();
      },
      onFailure: function(transport) {
        $('notice').update(transport.responseText);
        element.innerHTML = 'ERROR';
      }
    });
  }

  this.setStatus = function(statusStr) {
    status = statusStr;
    if(status == 'complete') {
      element.setStyle('background-color: #9FF;');
    } else if(status == 'incomplete') {
      element.setStyle('background-color: #FF9;');
    } else if(status == 'problem') {
      element.setStyle('background-color: #F88;');
    }
    isModified = true;
  }

  this.toggleState = function(stateNumber) {
    if(chrStates[stateNumber]) { // only toggle character states if they are defined
      statesArray[stateNumber] = statesArray[stateNumber] ? null : String(stateNumber);
      var outStr = statesArray.compact().join(" ");
      element.innerHTML = ( outStr == "" ) ? "----" : outStr;
      isModified = true;
      this.setStatus('complete');
    }
  }

  this.revert = function() {
    element.innerHTML = initInnerHTML;
    this.setStatus(initStatus);
    statesArray = initStatesArray.clone();
    isModified = false;
  }
}
MorphologyCell.prototype = (function() {
  return {
    constructor: MorphologyCell
  };
})();

function PlastomeCellObserver(cell) {
  Event.stopObserving('status_field', 'focus');
  Event.stopObserving('responsible_user_field', 'focus');
  Event.stopObserving('notes_field', 'focus');

  Event.stopObserving('status_field', 'blur');
  Event.stopObserving('responsible_user_field', 'blur');
  Event.stopObserving('notes_field', 'blur');

  Event.stopObserving('notes_field', 'keyup');

  $('status_field').observe('focus', function() { 
    this.up('tr').addClassName('highlighted');
  });
  $('responsible_user_field').observe('focus', function() {
    this.up('tr').addClassName('highlighted');
  });
  $('notes_field').observe('focus', function() {
    this.up('tr').addClassName('highlighted');
    // set and remove tabIndex for position in matrix to return to
    var taxonLink = $('r_' + cell.taxon_id).down('a')
    taxonLink.writeAttribute({
      tabIndex: parseInt(this.readAttribute('tabIndex')) + 1
    });
    taxonLink.observe('focus', function() {
      this.writeAttribute({ 
        tabIndex: null
      });
    }); 
  }); 


  $('status_field').observe('blur', function() {
    this.up('tr').removeClassName('highlighted');
  });
  $('responsible_user_field').observe('blur', function() {
    this.up('tr').removeClassName('highlighted');
  });
  $('notes_field').observe('blur', function() {
    this.up('tr').removeClassName('highlighted');
  });

  $('status_field').observe('change', function() {
    cell.setStatus($F('status_field'));
    var delay = function() { 
      cell.save();
    }.sleep(400);
  });

  $('status_field').observe('keyup', function() {
    cell.setStatus($F('status_field'));
    var delay = function() { 
      cell.save();
    }.sleep(400);
  });
  
  $('responsible_user_field').observe('change', function() {
    var resUserInitials = this.down('option[value="' + $F('responsible_user_field') + '"]').innerHTML.split(' ')[0];
    cell.setResponsibleUser(resUserInitials);
    var delay = function() { 
      cell.save();
    }.sleep(400);
  });

  $('responsible_user_field').observe('keyup', function() {
    var resUserInitials = this.down('option[value="' + $F('responsible_user_field') + '"]').innerHTML.split(' ')[0];
    cell.setResponsibleUser(resUserInitials);
    var delay = function() { 
      cell.save();
    }.sleep(400);
  });
  
  $('notes_field').observe('keyup', function() {
    cell.setNotes($F('notes_field') == "" ? false : $F('notes_field'));
    var delay = function() { 
      cell.save();
    }.sleep(400);
  });

  if($('genbank_number_field')) {
    $('genbank_number_field').observe('focus', function() {
      this.up('tr').addClassName('highlighted');
    });

    $('genbank_number_field').observe('blur', function() {
      this.up('tr').removeClassName('highlighted');
    });

    // check if genbank number given is valid at this time
    $('genbank_number_field').observe('keyup', function() {
      cell.setGenbankNumber($F('genbank_number_field') == "" ? false : true);
      var delay = function() {
        cell.checkGenbankNumber();
        cell.save();
        setTimeout("$('identifier_checker_result_text').fade();", 1000);
      }.sleep(650);
    });

    $('genbank_number_field').observe('change', function() {
      cell.setGenbankNumber($F('genbank_number_field') == "" ? false : true);
      cell.checkGenbankNumber();
      cell.save();
      setTimeout("$('identifier_checker_result_text').fade();", 1000);
    });
  }
}
PlastomeCellObserver.prototype = (function() {
  return {
    constructor: PlastomeCellObserver
  };
})();

function TaxonCellObserver(cell) {
  Event.stopObserving('notes_field', 'focus');
  Event.stopObserving('notes_field', 'blur');
  Event.stopObserving('notes_field', 'keyup')

  $('notes_field').observe('focus', function() {
    this.up('div').addClassName('highlighted');
    // set and remove tabIndex for position in matrix to return to
    var taxonLink = $('r_' + cell.taxonId).down('a')
    taxonLink.writeAttribute({
      tabIndex: parseInt(this.readAttribute('tabIndex')) + 1
    });
    //remove tabIndex value from main table once it has served its purpose
    taxonLink.observe('focus', function() {
      this.writeAttribute({
        tabIndex: null
      });
    });
  });
  $('notes_field').observe('blur', function() {
    this.up('div').removeClassName('highlighted');
  });
  $('notes_field').observe('keyup', function() {
    cell.setNotes($F('notes_field') == "" ? false : $F('notes_field'));
    var delay = function() {
      cell.save();
    }.sleep(400);
  });
}
TaxonCellObserver.prototype = (function() {
  return {
    constructor: TaxonCellObserver
  };
})();

// used for plastome table display.  may need to rename later on
function TaxonCell(element) {

  var isModified = false;
  var observer = null;
  

  var setTabOrders = function() {
    $('notes_field').writeAttribute({
      tabIndex: 1
    })
  }

  var updateInnerHTML = function() {
    var inHTML = "<a href='#'>" + element.down('a').innerHTML + "</a>"
    inHTML += notes ? "<img height='11' width='9' src='/images/paper_icon.png' alt='Paper_icon' />" : ""
    element.innerHTML = inHTML;
  }

  this.taxonId = /ch_([0-9]+)/.exec(element.id)[1];

  var notes = TOLKIN.getCurrentTable().rowHeaderNotes[this.taxonId];

  this.isModified = function() {
    return isModified;
  }

  this.save = function() {
    var cell = this;
    $('cell_details_form').request({
      onSuccess: function() {
        TOLKIN.getCurrentTable().rowHeaderNotes[cell.taxonId] = notes;
        $('cell_saved_message').appear({
          duration: '0.5',
          queue: {
            position: 'end',
            scope: 'save_message',
            limit: 2
          }
        });
        $('cell_saved_message').fade({
          duration: '0.5',
          queue: {
            position: 'end',
            scope: 'save_message',
            limit: 2
          }
        });
      },
      onFailure: function(transport) {
        $('notice').update(transport.responseText);
        element.innerHTML = 'ERROR';
      }
    });
  }

  this.setNotes = function(newNotes) {
    notes = newNotes
    updateInnerHTML();
    isModified = true;
  }

  this.showDetails = function() {
    var notesOrBlank = notes || ""
    var contents =
    "Taxon: " +
    element.down('a').innerHTML + "<br />\
      <span style='font-size: 16px'>\n\
      <a href='/projects/" + params['project_id'] + "/taxonomies/" + this.taxonId + "'>Go to page for this taxon</a></span><br /><br />\n\
      <form id='cell_details_form' action='/projects/" + params['project_id'] + "/plastome/tables/" + params['id'] + "/update_taxon_notes'>\n\
        <div>\n\
        (N)otes<br />\n\
        <input type='hidden' name='taxon_id' value='" + this.taxonId + "' />\n\
         <textarea id='notes_field', name='table_taxon[notes]', rows='5', cols='25'>" + notesOrBlank + "</textarea></div>\n\
    </form>\n\
    <div id='cell_saved_container'>\n\
      <div id='cell_saved_message' style='display: none;'>Saved</div></div>"

    if($('details_window')) {
      $('details_window').show();
      $('details_window_contents').update(contents);
    } else {
      $('contents').insert({
        top:
        "<div id='details_window' class='popup'>\n\
              <div class='window_title'>\n\
                <span class='title'>Cell Details</span>\n\
                <span class='closebutton' onclick='this.up(\".popup\").hide();'>X</span>\n\
              </div>\n\
              <div class='window_contents'>\n\
                <div class='notice_area'></div>\n\
                  <div id='details_window_contents'>" +
        contents +
        "</div></div></div>"
      });
      new Draggable('details_window');
      positionWindow('details_window');
    }
    setTabOrders();
    notes = $F('notes_field') == "" ? false : $F('notes_field');
    observer = new TaxonCellObserver(this);
  }
}
TaxonCell.prototype = (function() {
  return {
    constructor: TaxonCell
  }
});

function PlastomeCell(element) {
  var status;
  var observer = null;

  switch(element.getStyle('background-color')) {
    case 'rgb(255, 255, 153)' :
      status = 'incomplete';
      break;
    case 'rgb(153, 255, 255)' :
      status = 'complete';
      break;
    case 'rgb(255, 136, 136)' :
      status = 'problem';
  }

  var responsibleUser = null;
  var notes = null;
  var hasGenbankNumber = null;
  var genbankLink = null;
  var isModified = false;

  var matcher = /^(c)_([0-9]+)_([0-9]+)/;
  var matchArray = matcher.exec(element.id);

  var updateInnerHTML = function() {
    var inHTML = responsibleUser || (status == 'incomplete' ? "" : status)
    inHTML += notes ? " <img height='11' width='9' src='/images/paper_icon.png' alt='Paper_icon' />" : ""
    if(hasGenbankNumber) {
      inHTML += (genbankLink && genbankLink != "") ?
      " <a href='" + genbankLink + "' target='_blank'><img height='11' width='11' src='/images/genbank.gif' alt='Genbank' /></a>" :
      "<img height='11' width='11' src='/images/genbank.gif' alt='Genbank' />"
    }
    element.innerHTML = inHTML;
  }
  
  var setTabOrders = function() {
    var indexVal = 1;
    if($('genbank_number_field')) {
      $('genbank_number_field').writeAttribute({
        tabIndex: indexVal++
      })
    }
    $('status_field').writeAttribute({
      tabIndex: indexVal++
    })
    $('responsible_user_field').writeAttribute({
      tabIndex: indexVal++
    })
    $('notes_field').writeAttribute({
      tabIndex: indexVal++
    })
  }

  this.taxon_id = matchArray[2];
  this.column_id = matchArray[3];

  this.isModified = function() {
    return isModified;
  }

  this.save = function() {
    var cell = this;
    $('cell_details_form').request({
      method : 'put',
      onSuccess: function() {
        if(!TOLKIN.getCurrentTable().cellNotes[cell.taxon_id]) {
          TOLKIN.getCurrentTable().cellNotes[cell.taxon_id] = { }
        }
        TOLKIN.getCurrentTable().cellNotes[cell.taxon_id][cell.column_id] = notes;
        $('cell_saved_message').appear({
          duration: '0.5',
          queue: {
            position: 'end',
            scope: 'save_message',
            limit: 2
          }
        });
        $('cell_saved_message').fade({
          duration: '0.5',
          queue: {
            position: 'end',
            scope: 'save_message',
            limit: 2
          }
        });
      },
      onFailure: function(transport) {
        $('notice').update(transport.responseText);
        element.innerHTML = 'ERROR';
      }
    });
  }

  this.setStatus = function(statusStr) {
    status = statusStr;
    if(status == 'complete' || status == 'available') {
      element.setStyle('background-color: #9FF;');
    } else if(status == 'incomplete' || status == 'not available') {
      element.setStyle('background-color: #FF9;');
    } else if(status == 'problem') {
      element.setStyle('background-color: #F88;');
    }
    updateInnerHTML();
    isModified = true;
  }

  this.setResponsibleUser = function(user) {
    responsibleUser = user;
    updateInnerHTML();
    isModified = true;
  }

  this.setNotes = function(newNotes) {
    notes = newNotes
    updateInnerHTML();
    isModified = true;
  }

  this.setGenbankNumber = function(genbankNumber) {
    hasGenbankNumber = genbankNumber;
    updateInnerHTML();
    isModified = true;
  }

  this.checkGenbankNumber = function() {
    var cell = this;
    $('checker_results_and_link').replace(" <span id='identifier_checker' class='small neutral'><img src='/images/ajax-loader.gif' alt='loader icon' /> checking...</span>");
    new Ajax.Request('/molecular/resources/ncbi/e_utils/check_identifier?term=' + $F('genbank_number_field'), {
      method: 'get',
      onComplete: function(transport) {
        // identifier is not found
        if(204 == transport.status) {
          $('identifier_checker').replace("\
              <span id='checker_results_and_link'>\n\
                <span id='identifier_checker_result_text' class='small negative'>\n\
                  <img src='/images/red_circle_x.png'  width='16px' height='16px' alt='x icon' /> not found\n\
                </span>\n\
              </span>")
          cell.setGenbankLink("");
        // identifier is found
        } else if(200 == transport.status) {
          $('identifier_checker').replace("\
          <span id='checker_results_and_link'>\n\
            <a href='http://www.ncbi.nlm.nih.gov/nuccore/" + transport.responseText + "' target='_blank'>link</a>\n\
            &nbsp;&nbsp;\n\
            <span id='identifier_checker_result_text' class='small positive'>\n\
              <img src='/images/check.png' width='16px' height='16px' alt='check' /> found\n\
            </span>\n\
          </span>")
          cell.setGenbankLink("http://www.ncbi.nlm.nih.gov/nuccore/" + transport.responseText);
        }
      }
    });
  }

  this.setGenbankLink = function(linkText) {
    genbankLink = linkText;
    $('genbank_link_field').writeAttribute({
      value: linkText
    });
    updateInnerHTML();
    isModified = true;
  }

  this.showDetails = function() {
    var cell = this;
    new Ajax.Request('/projects/' + params['project_id'] + '/plastome/tables/' + params['id'] + '/cells/' + this.taxon_id + "-" + this.column_id, {
      method: 'get',
      onSuccess: function(transport) {
        if($('details_window')) {
          $('details_window').show();
          $('details_window_contents').update(transport.responseText);
        } else {
          $('contents').insert({
            top:
            "<div id='details_window' class='popup'>\n\
              <div class='window_title'>\n\
                <span class='title'>Cell Details</span>\n\
                <span class='closebutton' onclick='this.up(\".popup\").hide();'>X</span>\n\
              </div>\n\
              <div class='window_contents'>\n\
                <div class='notice_area'></div>\n\
                  <div id='details_window_contents'>" +
            transport.responseText +
            "</div></div></div>\n\
             <script type='text/javascript'>new Draggable('details_window')</script>"
          });
          positionWindow('details_window');
        }
        setTabOrders();
        status = $F('status_field');
        responsibleUser = $('responsible_user_field').down('option[value="' + $F('responsible_user_field') + '"]').innerHTML.split(' ')[0];
        notes = $F('notes_field') == "" ? false : $F('notes_field');
        if($('genbank_number_field')) {
          hasGenbankNumber = $F('genbank_number_field') == "" ? false : true;
          genbankLink = $F('genbank_link_field');
        }
        observer = new PlastomeCellObserver(cell);
      },
      onFailure: function(transport) {
        $('notice').update('An error has occurred in trying to retrieve cell details');
      }
    });
  }
}
PlastomeCell.prototype = (function() {
  return {
    constructor: PlastomeCell
  };
})();

function CellFocus(type, table) {

  var selectedElement = null;
  var selectedCell = null;

  var getSelectedColumnId = function() {
    var matcher = /^(c)_([0-9]+)_([0-9]+)/;
    var matchArray = matcher.exec(selectedElement.id);
    return matchArray[3];
  }

  var getSelectedColumnNumber = function() {
    if(/ch/.exec(selectedElement.id)) {
      return 0;
    } else {
      var charId = getSelectedColumnId();
      return $('ch_' + charId).readAttribute('col');
    }
  }

  var highlightElement = function(cell) {
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
    }
  }

  var unhighlightElement = function(cell) {
    switch(cell.getStyle('background-color')) {
      case 'rgb(119, 119, 119)' :
        cell.setStyle('background-color: #4E4E4E;');
        break;
      case 'rgb(255, 255, 153)' :
        cell.setStyle('background-color: #fde981;');
        break;
      case 'rgb(153, 255, 255)' :
        cell.setStyle('background-color: #9be6fd;');
        break;
      case 'rgb(255, 136, 136)' :
        cell.setStyle('background-color: #fe4f4f;');
    }
  }

  this.type = type;

  this.table = table;

  this.getSelectedCell = function() {
    return selectedCell;
  }

  this.goDown = function() {
    var colNumber = parseInt(getSelectedColumnNumber());
    var nextRow = selectedElement.up().next();
    var cell = nextRow ? nextRow.down("td:nth-child(" + (colNumber + 1) + ")") : null;
    this.goToCell(cell);
  }

  this.goLeft = function() {
    var cell = selectedElement.previous();
    this.goToCell(cell);
  }

  this.goRight = function() {
    var cell = selectedElement.next();
    this.goToCell(cell);
  }

  this.goToCell = function(cell) {
    if(cell && cell.id) {
      this.selectElement(cell)
    }
  }

  this.goUp = function() {
    var colNumber = parseInt(getSelectedColumnNumber());
    var prevRow = selectedElement.up().previous();
    var cell = prevRow ? prevRow.down("td:nth-child(" + (colNumber + 1) + ")") : null;
    this.goToCell(cell);
  }

  this.showCellDetails = function() {
    selectedCell.showDetails();
  }

  this.selectElement = function(element) {
    if(selectedElement) {
      unhighlightElement(selectedElement)
    }
    if(selectedCell && selectedCell.isModified()) { // save any cell changes to db before moving to a new cell
      selectedCell.save();
    }
    highlightElement(element);

    selectedElement = element;

    switch(this.type) {
      case 'morphology':
        var cellChrStates = this.table.chrStateDefs[getSelectedColumnId()] || [ ];
        selectedCell = new MorphologyCell(element, cellChrStates);
        break;
      case 'plastome':
        if(/ch/.exec(element.id)) {
          selectedCell = new TaxonCell(element);
        } else {
          selectedCell = new PlastomeCell(element);
        }
        break;
    }
  }

  this.unselectElement = function() {
    selectedCell && selectedCell.revert();
    selectedElement && unhighlightElement(selectedElement);
  }
}
CellFocus.prototype = (function() {
  return {
    constructor: CellFocus
  };
})();

function TableObserver(table) {

  Event.observe('table_body_container', 'scroll', function(event) {
    $('table_head_container').scrollLeft = $('table_body_container').scrollLeft;
  });

  Event.observe('table_body', 'mouseover', function(event) {
    if(table.getType() == 'plastome') {
      var hoverCell = Event.findElement(event, 'td');
      if(hoverCell) {
        var matchResults = /^c(h?)_([0-9]+)(_([0-9]+))?$/.exec(hoverCell.id);
        var tooltipContents;
        // cell is a row header
        if(matchResults[1]) {
          tooltipContents = table.rowHeaderNotes[matchResults[2]]
        // cell is a standard cell
        } else {
          tooltipContents = table.cellNotes[matchResults[2]] ? table.cellNotes[matchResults[2]][matchResults[4]] : null
        }
        if(tooltipContents) {
          table.showTooltip(tooltipContents, Event.pointerX(event), Event.pointerY(event));
        } else {
          table.hideTooltip();
        }
      }
    } else if (table.getType() == 'morphology') {
      var ele = Event.findElement(event, 'td');
      if (ele != undefined) {
        var reg = /^(ch?)_([0-9]+)_([0-9]+)/;
        var resArr = reg.exec(ele.id);
        if (resArr != null) {
          if (resArr[1] == 'c') {
            t = toolTips[resArr[3]];
            if (t == undefined)
              s(event, "NO STATES");
            else
              s(event, t);
          }
          else
          if (resArr[1] == 'ch')
            h();
        }
      }
    }
  });

  this.observeForStandardMode = function() {
    Event.observe('table_body','click',function(event){
      var ele = Event.findElement(event, 'td');
      var reg = /^(ch?)_([0-9]+)_([0-9]+)/;
      var resArr = reg.exec(ele.id);
      if ( resArr != null) {
        if (resArr[1] == 'c') {
          a(resArr[2], resArr[3]);
        }
        else
        {
          ele = Event.findElement(event, 'a');
          ele.getOffsetParent;
          resArr = reg.exec(ele.id);
          if(resArr[1] == 'ch'){
        //lch(resArr[]);
        }
        }
      }
    });
  }
  this.observeForQuickEditMode = function() {
    var cellFocus = table.getCellFocus();
    Event.observe(document, 'keydown', function(e) {
      var keycode = e.keycode ? e.keycode : e.which;
      // stop viewing window from scrolling without holding key
      if(keycode == Event.KEY_DOWN || keycode == Event.KEY_UP) {
        e.stop()
      }
    });
    Event.observe(document, 'keyup', function(e) {
      if(Event.element(e).tagName == 'SELECT' || Event.element(e).tagName == 'TEXTAREA' || Event.element(e).type == 'text') {
        return
      }
      var keycode = e.keycode ? e.keycode : e.which;
      var selectedCell = cellFocus.getSelectedCell();
      if(selectedCell) {
        if(keycode == Event.KEY_RETURN) {
          selectedCell.save();
        } else if(keycode == Event.KEY_ESC) {
          cellFocus.unselectElement();
        // number key pressed
        } else if((keycode >= 48 && keycode < 58) || (keycode >= 96 && keycode < 106)) {
          var keyDigit = keycode >= 96 ? keycode - 96 : keycode - 48;
          selectedCell.toggleState(keyDigit);
        // directional key pressed
        } else if(keycode >= 37 && keycode < 41) {
          if(keycode == Event.KEY_LEFT) {
            cellFocus.goLeft();
          } else if(keycode == Event.KEY_RIGHT) {
            cellFocus.goRight();
          } else if(keycode == Event.KEY_UP) {
            cellFocus.goUp();
          } else if(keycode == Event.KEY_DOWN) {
            cellFocus.goDown();
          }
          if(table.getType() == 'plastome') {
            var delayShowCellDetails = function() {
              cellFocus.showCellDetails()
            }.sleep(250);
          }
          e.stop();
        } else if(keycode >= keyCode('A') && keycode <= keyCode('Z')) {
          if(table.getType() == 'plastome') {
            if(keycode == keyCode('S')) {
              if($('status_field')) {
                $('status_field').focus();
              }
            } else if(keycode == keyCode('R')) {
              if($('responsible_user_field')) {
                $('responsible_user_field').focus();
              }
            } else if(keycode == keyCode('N')) {
              if($('notes_field')) {
                $('notes_field').focus();
              }
            } else if (keycode == keyCode('G')) {
              if($('genbank_number_field')) {
                $('genbank_number_field').focus();
              }
            }
          } else if(table.getType() == 'morphology') {
            if(keycode == keyCode('C')) {
              selectedCell.setStatus('complete');
            } else if (keycode == keyCode('I')) {
              selectedCell.setStatus('incomplete');
            } else if (keycode == keyCode('P')) {
              selectedCell.setStatus('problem');
            }
          }
        }
      }
    });

    Event.observe('table_body', 'click', function(event) {
      var clickedCell = Event.findElement(event, 'td');
      if(clickedCell) {
        cellFocus.selectElement(clickedCell);
        if(table.getType() == 'plastome') {
          cellFocus.showCellDetails();
        }
      }
    });



    Event.observe('table_body', 'mouseout', function(event) {
      table.hideTooltip();
    });
  }
}
TableObserver.prototype = (function() {
  return {
    constructor: TableObserver
  };
})();

function Tooltip(tooltipContents) {

  var container =
  "<div id='tooltip' class='tooltip'>\n" +
  "</div>"

  this.show = function(mousePosX, mousePosY) {
    if(!$('tooltip')) {
      $('contents').insert({
        after: container
      });
    }

    var tooltip = $('tooltip');
    tooltip.style.left= mousePosX + 5 + 'px';
    tooltip.style.top= mousePosY + 5 + 'px';
    tooltip.innerHTML= tooltipContents;
    tooltip.style.zIndex=20;
    tooltip.style.display="block";
  }

  this.hide = function() {
    if($('tooltip')) {
      $('tooltip').hide();
    }
  }
}
Tooltip.prototype = (function() {
  return {
    constructor: Tooltip
  };
})();

function Table(type, options) { 
  if(options == null) { 
    options = { }
  }
  

  var cellFocus = new CellFocus(type, this);
  var tooltip = null;

  this.getCellFocus = function() {
    return cellFocus;
  }

  var quickEditModeOn = false;
  var observer = new TableObserver(this);

  if(type == 'plastome') {
    observer.observeForQuickEditMode();
  } else {
    observer.observeForStandardMode();
  }

  

  var syncColumnWidths = function() {
    var matcher = /^(c)_([0-9]+)_([0-9]+)/;
    $$('table_body tr:first td').each(function(element) {
      var matchArray = matcher.exec(element.id);
      if(matchArray[2]) {
        element.setStyle({
          width: $('ch_' + matchArray[2]).getWidth() - 6 + 'px'
        })
      }
    });
  }
  syncColumnWidths();

  var setExpanderWidth = function() {
    $$('.table_body_expander').each( function(body_expander) {
      body_expander.setStyle({
        width: (body_expander.down('.table_body').getWidth()) + 'px'
      });
    });
  }
  setExpanderWidth();

  this.cellNotes = options['cellNotes'];
  this.rowHeaderNotes = options['rowHeaderNotes'];
  this.chrStateDefs = options['chrStateDefs'];

  this.getType = function() {
    return type;
  }

  this.hideTooltip = function() {
    if(tooltip) {
      tooltip.hide();
    }
  }

  this.showTooltip = function(tooltipContents, mousePosX, mousePosY) {
    tooltip = new Tooltip(tooltipContents);
    tooltip.show(mousePosX, mousePosY);
  }

  this.toggleQuickEditMode = function() {
    Event.stopObserving(document, "keydown");
    Event.stopObserving(document, 'keyup');
    Event.stopObserving('table_body', 'click');
    Event.stopObserving('table_body', 'mouseout');

    if(quickEditModeOn == true) {
      $('toggle_quick_edit_mode_link').update('Enter Quick Edit Mode')
      observer.observeForStandardMode();
      cellFocus.unselectElement();
      quickEditModeOn = false;
      TOLKIN.getNotifier().notice("Quick edit mode off")
    } else {
      $('toggle_quick_edit_mode_link').update('Exit Quick Edit Mode')
      observer.observeForQuickEditMode();
      quickEditModeOn = true;
      TOLKIN.getNotifier().notice("Quick edit mode on")
    }
  }
}
Table.prototype = (function() {
  return {
    constructor: Table
  };
})();

function TolkinInstance() {
  var currentTable = null;
  var notifier = new Notifier();

  this.getCurrentTable = function() {
    return currentTable;
  }

  this.getNotifier = function() {
    return notifier;
  }

  this.setCurrentTable = function(table) {
    currentTable = table;
  }

  this.visitTaxon = function(taxonId) {
    document.location = "/projects/" + params['project_id'] + "/taxonomies/" + taxonId
  }
}
TolkinInstance.prototype = (function() {
  return {
    constructor: TolkinInstance
  };
})();

var TOLKIN = new TolkinInstance();
