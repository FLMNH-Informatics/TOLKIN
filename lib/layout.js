if($('project_select')) {
  $('project_select').observe('change', function(event) {
    var match = window.location.pathname.match(/(.*)projects\/?(\d+)?(.*)/);
    window.location.pathname = match[1] + "projects" + ($F('project_select') ? "/" + $F('project_select') + match[3] : '');
  });
}
