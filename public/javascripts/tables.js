function setTableScrollObserver() {
  Event.observe('table_body_container', 'scroll', function(event) {
    $('table_head_container').scrollLeft = $('table_body_container').scrollLeft;
  });
}

