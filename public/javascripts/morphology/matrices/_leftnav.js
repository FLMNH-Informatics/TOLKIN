if($('goto_version_control')) {
  $('goto_version_control').observe('click', function(event) {
    version_number = $('matrix_version_number')
    $('matrix_version_number').replace("<form action='" + ID + "/redirect_to_version?authenticity_token=" + AUTH_TOKEN + "' method='post'><input type='text' id='matrix_version_number_field' name='version_number' size='1' /></form>");
    $('matrix_version_number_field').focus();
    $('matrix_version_number_field').observe('blur', function(event) {
      $('matrix_version_number_field').replace(version_number)
    });
  })
}
