
function itemSelectCheckboxes() {
  var elements = $$('.item_select_checkbox')
  elements.each (
    function(e) {
      e.observe('click', function() {this.parentNode.parentNode.toggleClassName('selected_row')});
    }
  );
}

function listItemRows() {
  var elements = $$('.list_item_row')
  elements.each (
    function(e) {
      e.observe('mouseover', function() {this.addClassName('highlighted_row')});
      e.observe('mouseout', function() {this.removeClassName('highlighted_row')});
    }
  );
}

window.onload = function() {
  itemSelectCheckboxes();
  listItemRows();
}

