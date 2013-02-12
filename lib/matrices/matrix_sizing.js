//function setMatrixBodyContainerWidth() {
//  $$('.table_body_container').each( function(body_container) {
//    //alert(body_container.getWidth() + ", " + body_container.down('.table_body').getWidth());
//    if(body_container.getWidth() > body_container.down('.table_body').getWidth()) {
//      body_container.setStyle({
//        width: (body_container.down('.table_body').getWidth() + 15) + 'px'
//      });
//    }
//  });
//}

function sizeTableContainers(bodyExpanderWidth) {
  var viewportWidth = document.viewport.getDimensions().width;
  var userPanelWidth = $('viewport').down('.user_panel').getDimensions().width;
  if(bodyExpanderWidth > 10) {
    $$('.table_head_container').each( function(head_container) {
      head_container.setStyle({
        width: ((bodyExpanderWidth + 20) > (viewportWidth - userPanelWidth - 110))? (viewportWidth - userPanelWidth - 110) + 'px' : (bodyExpanderWidth + 20) + 'px'
      });
    });
  }
  $$('.table_body_container').each( function(body_container) {
    body_container.setStyle({
      width: ((bodyExpanderWidth + 20) > (viewportWidth - userPanelWidth - 110))? (viewportWidth - userPanelWidth - 110) + 'px' : (bodyExpanderWidth + 20) + 'px'
    });
  });
}

function setTableBodyExpanderWidth() {
  var bodyExpanderWidth;
  $$('.table_body_expander').each( function(body_expander) {
    //alert(body_container.getWidth() + ", " + body_container.down('.table_body').getWidth());
    bodyExpanderWidth = body_expander.down('.table_body').getWidth();
    body_expander.setStyle({
      width: bodyExpanderWidth + 'px'
    });
  });
  sizeTableContainers(bodyExpanderWidth);
  Event.observe(document.onresize ? document : window, "resize", function() {
    sizeTableContainers(bodyExpanderWidth);
  });
}

function setTableCellWidth(otu_id, chr_id) {
  $("c_" + otu_id + "_" + chr_id).setStyle({
    width: ($('ch_' + chr_id).getWidth()) + 'px'
  });
}

function observeBranchVersions() {
  $('from_matrix_name_field').observe('blur', function() {
    new Ajax.Updater('from_matrix_version_select', '/projects/' + PROJECT_ID + '/morphology/matrices/select_for_branch_version',
    {
      method: 'get',
      parameters: {
        branch_name: $F('from_matrix_name_field')
      }
    })
  });
  $('to_matrix_name_field').observe('blur', function() {
    new Ajax.Updater('to_matrix_version_select', '/projects/' + PROJECT_ID + '/morphology/matrices/select_for_branch_version',
    {
      method: 'get',
      parameters: {
        branch_name: $F('to_matrix_name_field')
      }
    })
  });
}

function setTableScrollObserver() {
  Event.observe('table_body_container', 'scroll', function(event) {
    $('table_head_container').scrollLeft = $('table_body_container').scrollLeft;
  });
}

function lch(chr_id){
  window.open('/projects/' + proj_id + '/characters/' + chr_id);
};
function lo(project_id, otu_id){
  window.open('/projects/' + project_id + '/otus/' + otu_id);
};
