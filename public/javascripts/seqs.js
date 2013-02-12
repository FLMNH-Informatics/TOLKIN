
var featRowCount;
window.onload = function() {
featRowCount = 0;
}

function initializeValues()
{
featRowCount = 0;
positionWindow('add_sequence');
}

function removeRow(control_id)
{
    var seq = this;
    var splitArr=new Array();
    splitArr = control_id.id.split('_');
    var row_num = splitArr[splitArr.length - 1];
    var out = '';
    $('viewport').down('#seq_feature_row_' + row_num).replace(out);
    
}

function addVaueTextBox(control_id){
    var seq = this;
    var out;
    var splitArr=new Array();
    splitArr = control_id.id.split('_');
    var row_num = splitArr[splitArr.length - 1];
    var selected_qualifier = $(control_id.id).options[$(control_id.id).selectedIndex].text;
    switch(selected_qualifier){
        case "environmental_sample":
        case "pseudo":
        case "trans_splicing":
        case "focus":
        case "germline":
        case "macronuclear":
        case "partial":
        case "proviral":
        case "rearranged":
        case "ribosomal_slippage":
        case "transgenic":
            out= "<td class='b' id='#{id}' style='width: 30%;'>\n".interpolate({
              id: 'seq_val_col_' + row_num
            });
            out += "</td>\n";
            $('viewport').down('#seq_val_col_' + row_num).replace(out);
            //return out;
                break;
        default:
             out= "<td class='b' id='#{id}' style='width: 30%;'><input type='text' name='#{text_name}' id='#{text_id}'/>\n".interpolate({
              id: 'seq_val_col_' + row_num,
              text_name: 'dnasequence[seq_val_key_' + row_num + ']',
              text_id: 'dnasequence_seq_val_key_' + row_num
            });
            out += "</td>\n";
            $('viewport').down('#seq_val_col_' + row_num).replace(out);
            //return out;
                break;
    }

}

function addQualifierDD(control_id){
    var seq = this;
    var splitArr=new Array();
    splitArr = control_id.id.split('_');
    var row_num = splitArr[splitArr.length - 1];
    ///////////////////////////////////////////split here and extract the ID from ID_name
    var selected_feature_value = $(control_id.id).options[$(control_id.id).selectedIndex].value;
    var splitArrVal = new Array();
    splitArrVal = selected_feature_value.split('~');
     var selected_feature_id = splitArrVal[0];
    new Ajax.Request((params['path_prefix'] || '') + '/terms/get_qualifier_terms', {
        method: 'get',
        parameters: {feat_id: selected_feature_id},
        requestHeaders: { 'Accept' : 'application/json' },
        onSuccess: function (transport) {
            var response = transport.responseJSON;
//            seq.qualifiers = response.qualifiers;
//            var out= "<td class='b' id='#{id}' style='width: 25%;'><select id='#{select_id}' name='#{select_name}' onchange='addVaueTextBox(this);'>\n".interpolate({
//              id: 'seq_qual_col_' + row_num,
//              select_name: 'dnasequence[seq_qual_key_' + row_num + ']',
//              select_id : 'dnasequence_seq_qual_key_' + row_num
//            });
//            seq.qualifiers.each(function(qualifier){
//                  out += "  <option value='#{option_value}'#{option_selected}>#{option_name}</option>\n".interpolate({
//                    option_value: qualifier.term.term_id + "~" + qualifier.term.name,
//                    option_selected: 'gene' == qualifier.term.name ? " selected='selected'" : "",
//                    option_name: qualifier.term.name
//                  });
//            })
var out= "<td class='b' id='#{id}' style='width: 25%;'><select id='#{select_id}' name='#{select_name}' onchange='addVaueTextBox(this);'>\n".interpolate({
              id: 'seq_qual_col_' + row_num,
              select_name: 'dnasequence[seq_qual_key_' + row_num + ']',
              select_id : 'dnasequence_seq_qual_key_' + row_num
            });

              out += "  <option value='#{option_value}'#{option_selected}>#{option_name}</option>\n".interpolate({
                option_value: "gene",
                option_selected:  "selected='selected'",
                option_name: "Locus"
              });


            out += "</select>\n";
            out += "</td>\n";
            $('viewport').down('#seq_qual_col_' + row_num).replace(out);
            out= "<td class='b' id='#{id}' style='width: 30%;'><input type='text' name='#{text_name}' id='#{text_id}'/>\n".interpolate({
              id: 'seq_val_col_' + row_num,
              text_name: 'dnasequence[seq_val_key_' + row_num + ']',
              text_id: 'dnasequence_seq_val_key_' + row_num
            });
            out += "</td>\n";
            $('viewport').down('#seq_val_col_' + row_num).replace(out);
            //return out;
        }
    })
}

function addFeaturesRow(){
    var seq = this;
    featRowCount += 1;
    new Ajax.Request((params['path_prefix'] || '') + '/terms/get_features_terms', {
        method: 'get',
        parameters: {feat_count: featRowCount},
        requestHeaders: { 'Accept' : 'application/json' },
        onSuccess: function (transport) {
            var response = transport.responseJSON;
            seq.terms = response.terms;
            var out= "\
<tr id='#{id}'>\n\
  <td class='b' id='#{col_startloc_id}' style='width: 10%;'>\n\
    <input size='5' type='text' name='#{loc_start_name}' id='#{loc_start_id}'/>\n\
  </td>\n\
  <td class='b' id='#{col_end_id}' style='width: 10%;'>\n\
    <input size='5' type='text' name='#{loc_end_name}' id='#{loc_end_id}'/>\n\
  </td><td class='b' style='width: 25%;'>\n\
<select id='#{select_id}' name='#{select_name}' onchange='addQualifierDD(this);'>\n".interpolate({
              id: 'seq_feature_row_' + featRowCount,
              select_name: 'dnasequence[seq_feat_key_' + featRowCount + ']',
              select_id: 'dnasequence_seq_feat_key_' + featRowCount,
              col_startloc_id: 'col_startloc_' + featRowCount,
              loc_start_name: 'dnasequence[feat_loc_start_' + featRowCount + ']',
              loc_start_id: 'dnasequence_feat_loc_start_' + featRowCount,
              col_endloc_id: 'col_endloc_' + featRowCount,
              loc_end_name: 'dnasequence[feat_loc_end_' + featRowCount + ']',
              loc_end_id: 'dnasequence_feat_loc_end_' + featRowCount

            });
            seq.terms.each(function(term){
                  out += "  <option value='#{option_value}'#{option_selected}>#{option_name}</option>\n".interpolate({
                    option_value: term.term.term_id + "~" + term.term.name,
                    option_selected: 'gene' == term.term.name ? " selected='selected'" : "",
                    option_name: term.term.name
                  });
            })
            out += "</select>\n";
            out += "<input type='hidden' id='{hdn_id}' name='#{hdn_name}' value='#{hdn_value}'/>\n".interpolate({
                hdn_id: 'dnasequence_feat_count',
                hdn_name: 'dnasequence[feat_count]',
                hdn_value: featRowCount
            });
            out += "</td>\n";
            out += "<td class='b' id='#{id}' style='width: 25%;'></td>\n".interpolate({
              id: 'seq_qual_col_' + featRowCount
            });
            out += "<td class='b' id='#{id}' style='width: 30%;'></td>\n".interpolate({
              id: 'seq_val_col_' + featRowCount
            });
            out += "<td class='b' id='#{id}' style='width: 30%;'><input type='button' id='#{btnid}' name='#{btnval}' onclick='removeRow(this);' value='X'/></td>\n".interpolate({
              id: 'seq_del_col_' + featRowCount,
              btnid: 'dnasequence_row_del_' + featRowCount,
              btnval: 'dnasequence[row_del_' + featRowCount + ']'
            });
            out += "</tr><tr id='seq_feature_row_'></tr>";
            $('viewport').down('#seq_feature_row_').replace(out);
            addQualifierDD($('dnasequence_seq_feat_key_' + featRowCount));
            //return out;
        }
    })
}