function itemSelectCheckboxes() {
    var elements = $$('.item_select_checkbox')
    elements.each (
        function(e) {
            if(e.checked) {
                e.parentNode.parentNode.addClassName('selected_row');
            }
            e.observe('click', function() {
                this.parentNode.parentNode.toggleClassName('selected_row');
                if(this.checked == true){
              var str = this.up().next().down().innerHTML;
              buildElement(str, this.value);
                }
                else{
                    if($('sel_list_li_'+this.value)!=null){
                        $('sel_list_li_'+this.value).remove();
                    }
                }
            });
        }
        );
};

function add_selected_class(ele){
      ele.addClassName('selected_row');
    }
    function remove_selected_class(ele){
      ele.removeClassName('selected_row');
    }
    function add_highlight_class(ele){
      ele.addClassName('highlighted_row');
    }
    function remove_highlight_class(ele){
      ele.removeClassName('highlighted_row');
    }
    function remove_sel_item(ele_id){
      $("sel_list_li_" + ele_id).remove();
      tab_row_ele = $('list_item_'+ele_id);
      if(tab_row_ele != null){
        $('item_select_'+ele_id).checked = false;
        remove_selected_class(tab_row_ele);
      }
    };

//function buildElement(name, id){
//    //alert("name:" + name + "\nid:" + id)
//    var new_ele = "<li id='sel_list_li_"+ id +"'><input type='hidden'name='sel_items[]' value='" + id +"'/><a onclick='$(\"sel_list_li_" + id +"\").remove()' href='javascript:void(0)'>X</a></span> <span>"+name+"</span></li>";
//    if($('sel_list')!= null){
//        $('sel_list').insert(new_ele);
//    }
//    else{
//        //$('notice').replace("Oops! selected items list missing!.");
//    //send ajax call to admin
//    }
//}

function buildElement(name, id){
    // alert("name:" + name + "\nid:" + id)
    var new_ele = "<li id='sel_list_li_"+ id +"'><input type='hidden' name='sel_items[]' value='" + id +"'/><a onclick='remove_sel_item("+id+");' href='javascript:void(0)'>X</a></span> <span>"+name+"</span></li>";
    if($('sel_list')!= null){
        $('sel_list').insert(new_ele);
    }
    else{
        //$('notice').replace("Oops! selected items list missing!.");
    //send ajax call to admin
    }
  };
function listItemRows() {
    var elements = $$('.list_item_row')
    elements.each (
        function(e) {
            e.observe('mouseover', function() {
                this.addClassName('highlighted_row')
            });
            e.observe('mouseout', function() {
                this.removeClassName('highlighted_row')
            });
        }
        );
};
//window.onload = function() {
    itemSelectCheckboxes();
    listItemRows();
//};