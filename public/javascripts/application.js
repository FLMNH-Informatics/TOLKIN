// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function throwError(msg) {
  throw(msg);
}
function isNumber(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
}

var elementID = "";
function myPopupRelocate(){
  var scrolledX, scrolledY;
  if (self.pageYOffset) {
    scrolledX = self.pageXOffset;
    scrolledY = self.pageYOffset;
  }
  else
    if (document.documentElement && document.documentElement.scrollTop) {
      scrolledX = document.documentElement.scrollLeft;
      scrolledY = document.documentElement.scrollTop;
    }
  else
    if (document.body) {
      scrolledX = document.body.scrollLeft;
      scrolledY = document.body.scrollTop;
    }

  var centerX, centerY;
  if (self.innerHeight) {
    centerX = self.innerWidth;
    centerY = self.innerHeight;
  }
  else
    if (document.documentElement && document.documentElement.clientHeight) {
      centerX = document.documentElement.clientWidth;
      centerY = document.documentElement.clientHeight;
    }
  else
    if (document.body) {
      centerX = document.body.clientWidth;
      centerY = document.body.clientHeight;
    }
  topleft(scrolledX, scrolledY, centerX, centerY);
}

function topleft(scrolledX, scrolledY, centerX, centerY){
  var X = 350;
  var Y = 300
  if (elementID == "newformdiv" || elementID == "div_coll") {
    X = X - 700;
    Y = Y - 50
  }

  var leftOffset = scrolledX + (centerX - X) / 2;
  var topOffset = scrolledY + (centerY - Y) / 2;

  document.getElementById(elementID).style.top = topOffset + "px";
  document.getElementById(elementID).style.left = leftOffset + "px";
}

//window.onload = function(){
//  positionWindow('div_citation');
//  positionWindow('div_new_citation');
//}

function genbank_export_place(){
    elementID = "export_to_genbank";
    myPopupRelocate();
}

function cit_det(citation_id, project_id){
  onClick = $('div_citation').show();
  elementID = "div_citation";
  new Ajax.Updater({
    success: 'div_citation',
    failure: 'div_citation'
  }, '/projects/' + project_id + '/citations/' + citation_id, {
    asynchronous: true,
    evalScripts: true,
    method: 'get',
    parameters: {
      ajax: true
    }
  });
  myPopupRelocate();
  document.getElementById("div_citation").style.display = "block";
  document.body.onscroll = myPopupRelocate;
}
function show_div_new_citation(){
  onClick = $('div_new_citation').show();
  elementID = "div_new_citation";
  myPopupRelocate();
  document.getElementById("div_new_citation").style.display = "block";
  document.body.onscroll = myPopupRelocate;
}
function oBM(url) {
  testwindow = window.open("/tags/new?" + url, "mywindow", "scrollbars=1,width=500,height=200");
  if (window.screen) {
    var aw = screen.availWidth;
    var ah = screen.availHeight;
    testwindow.moveTo(aw / 2, ah / 2);
  }
}

function checkForCheckedItems() {
  var sel_list_items = $('sel_list').select('input[name=\"sel_items[]\"]');
  if(sel_list_items.size() > 0) {
    sel_list_items.each(function(element) {
      if($('item_select_'+element.value) != null) {
        $('item_select_'+element.value).checked = true;
        add_selected_class($('list_item_'+element.value));
      }
    });
  }
}

Function.prototype.sleep = function (millisecond_delay) {
	if(window.sleep_delay != undefined) clearTimeout(window.sleep_delay);
	var function_object = this;
	window.sleep_delay = setTimeout(function_object, millisecond_delay);
};

function keyCode(chrStr) {
  var chrCode = chrStr.charCodeAt(0);
  if(chrCode >= 65 && chrCode < 91) {
    return chrCode
  } else if(chrCode >= 97 && chrCode < 123) {
    return chrCode - 32;
  }
}

function submitColumns(form){
    form.form.submit();
}