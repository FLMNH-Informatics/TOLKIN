var elementID = "";
var selTax= "";
var isAPressed = false;
var isRPressed = false;

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
//    positionWindow('results');
//}
function checkAccuracySelected(value){
    if (value == $('collection_accuracy').length - 1) {
        $('collection_aux_accuracy').disabled = false;
    }
    else {
        $('collection_aux_accuracy').disabled = 'true';
    }
}

function c(project_id, coll_id){
    elementID = "div_coll";
    $('newformdiv').hide();
    new Ajax.Request('/projects/'+project_id+'/collections/' + coll_id, {
        asynchronous: true,
        evalScripts: true,
        method: 'get',
        parameters: {
            ajax: true
        }
    });
    myPopupRelocate();
}

function HighightSelectedTaxon(id){
	var temp = $("taxonomy_" + selTax.toString());
	if (temp != null) {
		temp.removeClassName('hl');
	}
	ele = $("taxonomy_" + id.toString());
	selTax = id;
	ele.addClassName('hl');
}
function HighightCurrentTaxon(){
	if (selTax != null) {
		ele = $("taxonomy_" + selTax.toString());
		ele.addClassName('hl');
	}
}
function DehightlightCurrentTaxon(){
	if (selTax != null) {
		ele = $("taxonomy_" + selTax.toString());
		ele.removeClassName('hl');
	}
}
document.onkeydown = function(e){
	var evt = e || window.event;
    
	if(evt.keyCode == 65)
	{
		isAPressed = true;
	}
	if(evt.keyCode == 82)
	{
		isRPressed = true;
	}
}
document.onkeyup = function(e){
    var evt = e || window.event;
    if(evt.keyCode == 65)
    {
        isAPressed = false;
    }
    if(evt.keyCode == 82)
    {
        isRPressed = false;
    }
}
function SelectTaxon(id, name){
    var temp = $("taxonomy_" + id);
    if (temp != null) {
        if (temp.hasClassName('sel')) {
            //temp.removeClassName('sel')
            remove_sel_item(id)
        }
        else {
            buildElement(name, id);
            temp.addClassName('sel');
        }
    }
    return false;
}
//no need of recursion thanks to functionality, on explore the children one level deep at a time.
function SelectRecursive(id, tax_name){
    var temp = $("taxonomy_" + id);
    if (temp != null) {
        if (temp.hasClassName('sel')) {
            //temp.removeClassName('sel');
            //recurse the children if present and remove
            $("node_"+ id + "_children").select("span[class~='tn']").each(function(ele){
                remove_sel_item( ele.id.substring(9))
                //ele.removeClassName('sel');
            });
            remove_sel_item(id);
        }
        else {
            temp.addClassName('sel');
            //iterate the children if present and add
            $("node_"+ id + "_children").select("span[class~='tn']").each(function(ele){
                ele.addClassName('sel');
                buildElement(ele.textContent, ele.id.substring(9)); //f9 for 'taxonomy_' since the id of nodes will be something like taxonomy_[id]
            });
            buildElement(tax_name, id);
        }
    }
}
function f(project_id, tax_id, tax_name){
    alert("WERW");
    if(isAPressed && isRPressed){
        return SelectRecursive(tax_id, tax_name);
    }
    else if(isAPressed){
        return SelectTaxon(tax_id, tax_name);
    }
    //HighightSelectedTaxon(tax_id);
    elementID = "results";
    $('newformdiv').hide();
    $('div_coll').hide();
    new Ajax.Updater({
        success: 'tdresults',
        failure: 'tdresults'
    }, '/projects/' + project_id + '/taxonomies/' + tax_id + '/taxon_details', {
        asynchronous: true,
        evalScripts: true,
        method: 'get'
    });
    assignparentnodeid(tax_id);
    myPopupRelocate();
    document.getElementById("results").style.display = "block";
    document.body.onscroll = myPopupRelocate;
}

function fnewtax(){
    elementID = "newformdiv";
	 myPopupRelocate();
    document.getElementById("newformdiv").style.display = "block";
    document.body.onscroll = myPopupRelocate;
}

function fc(project_id, id){
	var parHsh = null;
	if($("taxonomy_"+id).hasClassName('sel'))
	{
		parHsh = {
			selected : true
		}
	}
    new Ajax.Updater('node_' + id, '/projects/' + project_id + '/taxonomies/' + id + '/fetch_children', {
        asynchronous: true,
        method: 'get',
        evalScripts: true,
		parameters: parHsh,
        onComplete: function(request){
			HighightCurrentTaxon();
            new Effect.Appear("node_" + id + "_children", {
                duration: 2
            });
        }
    });
    return false;
}

var parentID = -1;
function validate_required(field, alerttxt){
    with (field) {
        if (field.value == null || field.value == "") {
            return false;
        }
        else {
            return true;
        }
    }
}

function validate_newnodeform(thisform){
    with (thisform) {
        if (validate_required($('taxonomy_name'), "Please enter a name") == false) {
            $('taxonomy_name').focus();
            return false;
        }
        else {
            return true;
        }
    }
}

function assignparentnodeid(id){
    parentID = id;
    document.getElementById('sop_parentTaxon').value = id;
    //$('sop_parentTaxon').hide();
    $('lblresult').update("");
}

function hidenewformdiv(id){
    parentID = id
    $('newnodepanel').toggle();
}

function savenoderemote(formid){
    var hash = $(formid).serialize(true);
    hash.id = parentID;
    new Ajax.Updater("lblresult", "/taxonomies/savenode", {
        asynchronous: true,
        evalScripts: true,
        parameters: hash
    });
}
function remove_sel_item(tax_id){
    if('sel_list_li_' + tax_id.toString())
        $('sel_list_li_' + tax_id.toString()).remove();
    unselect_taxonomy(tax_id);
};

function unselect_taxonomy(tax_id){
    if($('taxonomy_'+tax_id.toString()).hasClassName('sel'))
        $('taxonomy_'+tax_id.toString()).removeClassName('sel');
}

function new_accepted_name_display(){
   var type = $('taxon_namestatus_id').value;
   if(type==2 || type==3){
      $('new_accepted_name_box').style.display = 'table-row';
   }else{
      $('new_accepted_name_box').style.display = 'none';
   }
}