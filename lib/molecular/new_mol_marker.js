function locationInput(type){
//  return '<input style="width:60px;" name="' + type + '_marker[position][]" type="text"/>' + '(<span style="font-style:italic; font-size:80%;">###..###</span>)';
  return '<td><input style="width:30px;" name="' + type + '_marker[start_position][]" type="number"/></td><td><input style="width:30px;" name="'+type+'_marker[end_position][]"/></td>';
}

function showMarkerFields(el, page){
  var cancelNew = '<a class="remove_seq"><img src="/images/16-em-cross.png" alt="don\'t save" /></a>'
    , addType = el.innerHTML.gsub('+', '');

  switch (addType){
    case 'new':
      el.up('tr').insert({
        before: '<tr style="font-size: 80%;"><td>' + cancelNew + '</td>' +
          '<td><input name="seq_marker[name][]" style="width:140px;" type="text"/></td>' +
          '<td><select name="seq_marker[type][]" style="width:130px;"/>' +
          '<option>gene</option>' +
          '<option>misc_RNA</option>' +
          '<option>rRNA</option>' +
          '</select></td>' +
          locationInput('seq') + '</tr>'
      });
      addDelObserver(el);
    break;
    case 'existing':
      if (page._selectControl){
        el.up('tr').insert({before: '<tr style="font-size: 80%;"><td>' + cancelNew + '</td><td colspan="2">' + page._selectControl + '</td>' + locationInput('mol') + '</tr>'});
        addDelObserver(el);
      }else{
        new Ajax.Request('/projects/' + params['project_id'] + '/molecular/sequences/new_sequence_marker_select', {
          method: 'get',
          requestHeaders: {Accept:'text/html'},
          parameters: {},
          onSuccess: function (response) {
            el.up('tr').insert({
              before: '<tr style="font-size: 80%;"></tr><td>' + cancelNew + '</td><td colspan="2">' + response.responseText + '</td>' + locationInput('mol') + '</tr>'
            });
            page.setSelectControl(response.responseText);
          },
          onFailure: function (response) {},
          onComplete: function (response) {
            addDelObserver(el);
          }
        });
      }
    break;
  }
}

function addDelObserver(el){
  el.up('tr').previous().down('td').down('a').observe('click', delMarkerRow);
}
function delMarkerRow(){
  this.up(1).remove();
}

function showChooseMarkerField(el){
  el.up('tr').insert({before: '<td></td>'});
}