//window.onload = function(){
//    positionWindow('div_coll');
//}
var elementID = "";


function c(coll_id, project_id){
    elementID = "div_coll";
    new Ajax.Updater({
        success: 'div_coll',
        failure: 'div_coll'
    }, '/projects/' + project_id + '/collections/' + coll_id, {
        asynchronous: true,
        evalScripts: true,
        method: 'get',
        parameters: {
            ajax: true
        }
    });
	$('div_coll').show();
}

function addRowToTable(){

    var tbl = document.getElementById('collection_tblSample');
    var lastRow = tbl.rows.length;
    // if there's no header row in the table, then iteration = lastRow + 1
    var iteration = lastRow;
    var row = tbl.insertRow(lastRow);

    // right cell
    var cellRight = row.insertCell(0);
    var el = document.createElement('input');
    el.type = 'text';
    el.name = 'annotation' + iteration + '[taxon]';
    el.id = 'txtRow' + iteration + '_taxon';
    el.size = 10;
    cellRight.appendChild(el);

    cellRight = row.insertCell(1);
    el = document.createElement('input');
    el.type = 'text';
    el.name = 'annotation' + iteration + '[name]';
    el.id = 'txtRow' + iteration + '_name';
    el.size = 10;
    cellRight.appendChild(el);

    cellRight = row.insertCell(2);
    el = document.createElement('input');
    el.type = 'text';
    el.name = 'annotation' + iteration + '[date]';
    el.id = 'txtRow' + iteration + '_date';
    el.size = 10;
    cellRight.appendChild(el);

    cellRight = row.insertCell(3);
    el = document.createElement('input');
    el.type = 'text';
    el.name = 'annotation' + iteration + '[inst]';
    el.id = 'txtRow' + iteration + '_inst';
    el.size = 10;
    cellRight.appendChild(el);
    // select cell

}

function removeRowFromTable(){
    var tbl = document.getElementById('collection_tblSample');
    var lastRow = tbl.rows.length;
    if (lastRow > 1)
        tbl.deleteRow(lastRow - 1);
}

//function itemSelectCheckboxes() {
//
//      var elements = $$('.checkbox_cell')
//      $('viewport_content_frame_collection_catalog').down('.header').down('input[type=checkbox]').setAttribute('onclick', 'selectAllCheckboxAction(this,"page_1_collections_listing")');
//      $('lnk_del_sel').setAttribute('onclick','delete_collections()')
//      elements.each (add_click_events_and_style_to_element);
//    }

    function add_click_events_and_style_to_element(e) {
        e = e.childElements()[0];
      if(e.checked) {
        e.parentNode.parentNode.addClassName('selected_row');
      }

      e.observe('click', function() {          
        //this.parentNode.parentNode.toggleClassName('selected_row');
         var name = this.parentNode.nextSiblings()[0].innerHTML +" "+this.parentNode.nextSiblings()[1].innerHTML;
         var value = this.parentNode.parentNode.parentNode.parentNode.parentNode.readAttribute('data-id');
        if($('div_sel_list')) {
          if(this.checked == true){

            buildElement(name, value);

          }
          else{
            if($('sel_list_li_'+value)!=null){
              $('sel_list_li_'+value).remove();
            }
          }
        }
      });
    };

    function selectAllCheckboxAction(mainCheckbox, table_id) {
        if(mainCheckbox.checked == true) {
         $(table_id).select('.checkbox_cell').each(function(checkbox) { if(checkbox.childElements()[0].checked == false) { checkbox.childElements()[0].click(); } });
        } else {
          $(table_id).select('.checkbox_cell').each(function(checkbox) {  if(checkbox.childElements()[0].checked == true) { checkbox.childElements()[0].click(); }});
        }
      }

      function remove_sel_item(ele_id){              
      $("sel_list_li_" + ele_id).remove();
      tab_row_ele = $('viewport_content_frame_collection_catalog').down('div[data-id='+ele_id+']');
      
      if(tab_row_ele != null){
          alert(tab_row_ele.down('input[type=checkbox]').checked )
        tab_row_ele.down('input[type=checkbox]').checked = false;        
        tab_row_ele.down('.selected_row').removeClassName('selected_row');
        
      }
    }
    

    function delete_collections(){
        var hasConfirmed = confirm('Are you sure you would like to delete the selected collections?');
        if(hasConfirmed) {
            $('form_sel_list').writeAttribute('action','/projects/' + params['project_id'] + '/collections/delete_selected');
            $('form_sel_list').writeAttribute('method','post');
            $('form_sel_list').submit();
            $('form_sel_list').writeAttribute('action','');
        }
    }
