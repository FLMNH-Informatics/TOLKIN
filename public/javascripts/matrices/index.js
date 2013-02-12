function toggleSubmatrixOptions() {
  var select_field = $('import_as');
  var display_field = $('submatrix_options');
  var parent_name_field = $('parent_name_field');

  if(select_field.value=='submatrix') {
    display_field.show();
    parent_name_field.focus();
  } else {
    display_field.hide();
    parent_name_field.value = '';
  }
}