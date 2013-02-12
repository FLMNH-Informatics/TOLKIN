 JooseRole('TaxaHelper', {
//  has: {
//    context: { is: 'ro', init: function () { return this.frame() } }
//  },

  methods: {


  _button : function() {
  //            if(params['action']=="tree_view")
  //            {
    if(this.frame().interactMode()=="edit") {
        return '<table><tr><td style="width:670px"><input type="submit" value="save" /></td>'+
        "<td><a target='_blank' href='"+this.context().routes().pathFor('project_taxon_path',{id: this.taxon().id()})+"'>View as Page</a></td></tr></table>";
    }
    return "<table><tr><td style='width:750px;' align='right'><a target='_blank' href='"+this.context().routes().pathFor('project_taxon_path',{id: this.taxon().id()})+"'>View as Page</a></td></tr></table>";
  //            }
  //            else
  //            {
  //                if(this.frame().interactMode()=="edit")
  //                {
  //                    return '<table><tr><td style="width:670px"><input type="submit" value="save" /></td></tr></table>'
  //                }
  //                return "";
  //            }
  },


  _header : function()
  {
//        str=""
//        temp1=""
//        temp2=""
//        temp3=""
//        temp4=""
//        alert(this.taxon().attributes().parent);
//        if(this.taxon().attributes().parent().parent())
//            temp1=this.taxon().attributes().parent().parent().name();
//        str+=temp1;
//        if(this.taxon().attributes().parent())
//            temp2=this.taxon().attributes().parent().name();
//        if (temp1=="" || temp2=="")
//            str+="";
//        else
//            str+=" > ";
//        str+=temp2
//        if(this.taxon().attributes().sub_genus())
//            temp3+=this.taxon().attributes().sub_genus();
//        if (temp2=="" || temp3=="")
//            str+="";
//        else
//            str+=" > ";
//        str+=temp3
//        if(this.taxon().attributes().section())
//            str+="Section "+this.taxon().attributes().section();
//        if (temp3=="" || temp4=="")
//            str+="";
//        else
//            str+=" > ";
//        str+=temp4;
  },

  _name : function()
  {
    var taxon = this.taxon().attributes();
    var str = "";
    var comma="";
    if(this._authorAndProtologue(taxon)!="<br /><br />")
        comma=",";
    else
        comma="";
    if (this.taxon().attributes().name) {
      switch(this.frame().interactMode().toString()) {
        case 'browse':
          str = "<span style='font-size: 16px; font-weight: bold;'>"+this.taxon().attributes().name+"</span>&nbsp;&nbsp;" ;
          break;
        case 'edit'  :
          str = "<input type='text' size='54' name='taxon[name]' value='"+this.taxon().attributes().name+"' />";
      }
      str += this._authorAndProtologue(taxon);

    } else {
      if(this.frame().interactMode() == 'browse') {
        str+="<span class='empty'>  None </span>";
      } else {
        str+="<input type='text' size='54' name='taxon[name]' value='' />";
      }

    }

    return str;

  },

_addRowToTable:function(){

      var tbl = document.getElementById('taxa_relationships_table');
      var lastRow = tbl.rows.length;
      // if there's no header row in the table, then iteration = lastRow + 1
      var iteration = lastRow;
      var row = tbl.insertRow(lastRow);

      // right cell
      var cellRight = row.insertCell(0);
      cellRight.appendChild(document.createTextNode(this.taxon().attributes().name));

      var selector = document.createElement('select');
      selector.name = "taxon[relationship"+iteration+"]";

      var predicates=['is parent of','has parent','is basionym of','has basionym','is accepted name of','has accepted name']

      for(var i=0;i<predicates.length;i++)
      {
          var option = document.createElement('option');
          option.value = i;
          option.appendChild(document.createTextNode(predicates[i]));
          selector.appendChild(option);
      }

      cellRight = row.insertCell(1);
      cellRight.appendChild(selector);

      cellRight = row.insertCell(2);
      cellRight.innerHTML=this.widgets().get('chooseTaxonComboBox').render().replace("chosen","chosen"+iteration);
  },

   _removeRowFromTable:function(){
      var tbl = document.getElementById('taxa_relationships_table');
      var lastRow = tbl.rows.length;
      if (lastRow > 1)
          tbl.deleteRow(lastRow - 1);
  },

  _relationships: function()
  {
   str='<div id="taxa_relationships">'+
      '<input class="add_button" type="button" value="Add"/><input class="remove_button" type="button" value="Remove"/>'+
      '<table border="1" style="border:1px dotted; border-collapse: collapse" id="taxa_relationships_table">'+
          '<tr><td>Current Taxon</td><td>Relationship</td><td>Choose Taxon</td></tr>'+
      '</table>'+
  '</div>';

return str;
  },


  _authorAndProtologue: function (atts) {
    var authPub,authProto;
    switch(this.frame().interactMode().toString()){
    case 'edit':
    var auth= "<input type='text' style='width: 100%' name='taxon[author]' " + ((atts.author && !atts.author.blank()) ? "value='"+atts.author+"'" : '') + " />";
    var pub=(atts.publication && !atts.publication.blank()) ? "<input type='text' size='60' name='taxon[publication]' value=\""+atts.publication+"\" />" :  "<input type='text' size='60' name='taxon[publication]' />";
    var vol=(atts.volume_num && !atts.volume_num.blank()) ?   "<input type='text' size='5' name='taxon[volume_num]' value='"+atts.volume_num+"' />" : "<input type='text' size='5' name='taxon[volume_num]' />";
    var pag=(atts.pages && !atts.pages.blank()) ? "<input type='text' size='10' name='taxon[pages]' value='"+atts.pages+"' />"                        : "<input type='text' size='10' name='taxon[pages]' />";
    var y=(atts.publication_date && !atts.publication_date.blank())? "<input type='text' size='13' name='taxon[publication_date]' value='"+atts.publication_date+"' />"  : "<input type='text' size='13' name='taxon[publication_date]' />";
    var inn= "<input type='text' style='width: 100%' name='taxon[infra_name]' " + ((atts.infra_name && !atts.infra_name.blank()) ? "value='"+atts.infra_name+"'" : '') + " />";
    var ina= "<input type='text' style='width: 100%' name='taxon[infra_author]' "+((atts.infra_author && !atts.infra_author.blank()) ?  "value='"+atts.infra_author+"'" : '') + " />";
    authProto =
      "<div style='margin:5px;' id='view_protologue_link'></div><div id='add_protologue_holder'></div>" +
      "<table>"+
        "<tr></tr>"+
        "<tr><td>Author: </td><td colspan='3'>"+auth+"</td></tr>"+
        "<tr>"+
          "<td>Publication: </td>"+
          "<td colspan='5'>"+pub+"</td>"+
        "</tr>"+
        "<tr>"+
          "<td>Volume: </td>"+
          "<td>"+vol+"</td>"+
          "<td>Pages: </td>"+
          "<td>"+pag+"</td>"+
          "<td>Year: </td>"+
          "<td>"+y+"</td>"+
        "</tr>"+
        "<tr>"+
          "<td>Infra Name: </td>"+
          "<td colspan='3'>"+inn+"</td>"+
          "<td>Infra Author: </td>"+
          "<td>"+ina+"</td>"+
        "</tr>"+
      "</table>";
    break;

    case 'browse':
      authProto = ""+
        ((!atts.author || atts.author.blank()) && (!atts.infra_author || atts.infra_author.blank()) ? "" : (atts.author||atts.infra_author)+", ")+
        (!atts.publication || atts.publication.blank() ? "" : "<span class='protologue_publication_name'>"+atts.publication+"</span> ")+
        (!atts.volume_num  || atts.volume_num.blank()  ? "" : atts.volume_num+": ")+
        (!atts.pages || atts.pages.blank() ? "" : atts.pages+". ")+
        (!atts.publication_date  || atts.publication_date.blank() ? "" : atts.publication_date+".");

      if (this.taxon().attributes().protologue){
         if (authProto.blank()){
            authProto = "<a target='_blank' title='Click to download protologue file' href='"+ this.context().routes().pathFor('get_protologue_project_taxon_path') + "'><b>Protologue File</b></a>";
         }else{
            authProto = "<a target='_blank' title='Click to download protologue file' href='"+ this.context().routes().pathFor('get_protologue_project_taxon_path') + "'>" +authProto + "</a>";
         }
      }

      authProto += "<br /><br />"//        authPub =
  //        [ (atts.author && !atts.author.blank()) ? atts.author : null,
  //          (atts.publication && !atts.publication.blank()) ? "<span class='protologue_publication_name'>"+atts.publication+".</span>" : null
  //        ].compact().join(', ')
  //
  //       authProto =
  //        [ authPub         && !authPub.blank()         ? authPub         : null,
  //          atts.volume_num && !atts.volume_num.blank() ? atts.volume_num : null,
  //          atts.pages      && !atts.pages.blank()      ? atts.pages      : null,
  //          atts.publication_date       && !atts.publication_date.blank()       ? atts.publication_date       : null
  //        ].compact().join(' ')
    }
    return authProto;
  },

      _namestatusSelect: function() {
      var output;
      var nameStatus = this.taxon().attributes().namestatus;
      switch(this.frame().interactMode().toString()) {
        case 'edit'  :
          output ="<select id='namestatus_select' name='taxon[namestatus_id]'>" +
          "<option value='13'" + (nameStatus && nameStatus.namestatus.id == 13 ? "selected='selected'" : '') + ">None</option>" +
          "<option value='1' " + (nameStatus && nameStatus.namestatus.id == 1 ?  "selected='selected'" : '') + ">Accepted Name</option>" +
          "<option value='2' " + (nameStatus && nameStatus.namestatus.id == 2 ?  "selected='selected'" : '') + ">Basionym</option>" +
          "<option value='3' " + (nameStatus && nameStatus.namestatus.id == 3 ?  "selected='selected'" : '') + ">Synonym</option>" +
          "<option value='4' " + (nameStatus && nameStatus.namestatus.id == 4 ?  "selected='selected'" : '') + ">Doubtful synonym</option>" +
          "<option value='5' " + (nameStatus && nameStatus.namestatus.id == 5 ?  "selected='selected'" : '') + ">Invalid</option>" +
          "<option value='6' " + (nameStatus && nameStatus.namestatus.id == 6 ?  "selected='selected'" : '') + ">Misapplied name</option>" +
          "<option value='7' " + (nameStatus && nameStatus.namestatus.id == 7 ?  "selected='selected'" : '') + ">Spelling variant</option>" +
          "<option value='8' " + (nameStatus && nameStatus.namestatus.id == 8 ?  "selected='selected'" : '') + ">Nom nud</option>" +
          "<option value='9' " + (nameStatus && nameStatus.namestatus.id == 9 ?  "selected='selected'" : '') + ">Nom illeg</option>" +
          "<option value='10'" + (nameStatus && nameStatus.namestatus.id == 10 ? "selected='selected'" : '') + ">Nom nov</option>" +
          "<option value='11'" + (nameStatus && nameStatus.namestatus.id == 11 ? "selected='selected'" : '') + ">Unpublished</option>" +
          "<option value='12'" + (nameStatus && nameStatus.namestatus.id == 12 ? "selected='selected'" : '') + ">Unplaced</option>" +
          "</select>";
          return output;
        default :
          if(nameStatus) {
            output = nameStatus.namestatus.status.gsub('_', ' ');
          } else {
            output ="<span class='empty'>No Description</span>";
          }
          return output;
      }
    },

    _synonyms_table : function() {
      var str="";
      if (this.taxon().attributes().synonyms) {
        var total = this.taxon().attributes().synonyms.length;
        for (var i=0;i<total;i++) {
          str += "<i>"+this.taxon().attributes().synonyms[i].name+"</i>";
          str += " "+this._authorAndProtologue(this.taxon().attributes().synonyms[i]);
          str += "<br>";
        }
      } else {
        str+="<span class='empty'>  No synonyms </span>";
      }
      return str;
    },


    _uploadSuccess: function (file, serverData) {
      try {
        var parts=new Array();
        parts=serverData.split('_');
        var extension=new Array();
        extension=parts[1].split('.');
        var progress = new FileProgress(file,  this.customSettings.upload_target);

        if (serverData.substring(0, 7) === "/images") {
          addImage(serverData);


          progress.setStatus("Thumbnail Created.");
          progress.toggleCancel(false);

          var tbl = document.getElementById('taxon_images');
          var row = tbl.insertRow(-1);
          var cell=row.insertCell(0);
          var newText="<a target='_blank' href='"+parts[0]+extension[1]+"'><img class='noborderimage' height='100' width='100' src='"+serverData+"'/></a>"
          // var newText="hi";
          cell.update(newText);
        } else {
          addImage("/images/error.gif");
          progress.setStatus("Error.");
          progress.toggleCancel(false);

        }
      } catch (ex) {
        this.debug(ex);
      }
    },

  _protologueOutput: function(){
//    var output = 'link to protologue';
//    var me = this;
  
   if(this.frame().interactMode().toString() == 'edit'){
      if($('add_protologue_holder')) {
        //      var swfu;
//      window.onload = function () {
        var bText = '';

        if (this.taxon().attributes().protologue) {
          var link = "<a target='_blank' title='Click to download protologue file' href='" + this.context().routes().pathFor('get_protologue_project_taxon_path') + "' ><b>Protologue File</b></a>";
          link += " | <a href='#' id='delete_protologue'>Delete File</a>";
          $('view_protologue_link').innerHTML = link;
          bText = "&nbsp;<span class='protologue_upload_link' >Change Protologue File (3 MB Max)</span>";
        } else {
          bText = "&nbsp;<span class='protologue_upload_link' >Add Protologue File (3 MB Max)</span>";
        }
        var me = this;
        //DISABLED for DEMO
        this.swfu = new SWFUpload({
          upload_url : this.context().routes().pathFor('add_protologue_project_taxon_path'),//, {taxon_id: params['id'] }),
          flash_url : (params['path_prefix'] || '') + '/assets/swfupload.swf',
          file_size_limit : "3 MB",
          post_params: {},
          button_placeholder_id : 'add_protologue_holder',
          button_width: 200,
          button_height: 20,
          button_text : bText,
          button_text_style : '.protologue_upload_link { font-family: Helvetica, Arial, sans-serif; color: #0066CC; font-size: 12pt; }',
          button_action : SWFUpload.BUTTON_ACTION.SELECT_FILES,
          button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
          button_cursor: SWFUpload.CURSOR.HAND,

          file_upload_limit            : 8, //FIXME this is to avoid queue errors on changing file
          file_queue_limit             : 1,
          file_queue_error_handler     : me._onFileQueueError.bind(this),
          upload_error_handler         : me._onUploadError.bind(this),
          file_dialog_complete_handler : me._onFileDialogComplete,
          upload_progress_handler      : me._onUploadProgress,
          upload_success_handler       : me._onUploadSuccess.bind(this),
          upload_complete_handler      : me._onUploadComplete.bind(this),
          upload_start_handler         : me._onUploadStart.bind(this),

          custom_settings : {
            upload_target : 'divFileProgressContainer'
          }//,
          // Flash Settings

          // debug: true
        });

      }

//      };
//      output = swfu;
//   }else{
//
//       link = '';
//      if (this.taxon().attributes().protologue){
//        //link = "<a target='_blank' title='Click to download protologue file' href='" + this.context().routes().pathFor('get_protologue_project_taxon_path') + "' ><b>Protologue File</b></a>";
//        //$('view_protologue_link').replace(link);
//      }else{
//        //$('add_protologue_holder').replace('<em>None</em>');
//        //link = '<em>None</em>';
//      }
//      //var div = document.getElementById('protologue_div');
//
//   }
//    return output;
    }
  },

  _onUploadError: function(file, errorCode, message) {
        var notifier = this.notifier();
        var progress;
        try {
          switch (errorCode) {
            case SWFUpload.UPLOAD_ERROR.FILE_CANCELLED:
              try {
                progress = new FileProgress(file,  this.customSettings.upload_target);
                progress.setCancelled();
                progress.setStatus("Cancelled");
                progress.toggleCancel(false);
              }
              catch (ex1) {
                this.debug(ex1);
              }
              break;
            case SWFUpload.UPLOAD_ERROR.UPLOAD_STOPPED:
              try {
                progress = new FileProgress(file,  this.customSettings.upload_target);
                progress.setCancelled();
                progress.setStatus("Stopped");
                progress.toggleCancel(true);
              }
              catch (ex2) {
                this.debug(ex2);
              }
            case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
              notifier.error('Upload limit exceeded.')
              break;
            default:
              notifier.error(message);
              break;
          }
        } catch (ex3) {
          this.debug(ex3);
        }
    },
    _onFileQueueError: function(file, errorCode, message) {
      var notifier = this.notifier();
      switch (errorCode) {
        case SWFUpload.errorCode_QUEUE_LIMIT_EXCEEDED:
          notifier.error("Too many files queued for upload.");
          break;
        case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
          notifier.error("Zero byte file found in upload queue.");
          break;
        case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
          notifier.error("File queued for upload is too big.");
          break;
        case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
          notifier.error("One of the files queued for upload has an invalid filetype.");
          break;
        default:
          notifier.error("File queue error encountered: "+message);
      }
    },

    _onFileDialogComplete: function(numFilesSelected, numFilesQueued) {
      try {
        if (numFilesQueued > 0) {
          this.startUpload();
        }
      } catch (ex) {
        this.debug(ex);
      }
    },

    _onUploadProgress: function(file, bytesLoaded) {

      try {
        var percent = Math.ceil((bytesLoaded / file.size) * 100);

        var progress = new FileProgress(file,  this.customSettings.upload_target);
        progress.setProgress(percent);
        if (percent === 100) {
          //progress.setStatus("Creating File...");
          progress.toggleCancel(false, this);
        } else {
          progress.setStatus("Uploading...");
          progress.toggleCancel(true, this);
        }
      } catch (ex) {
        this.debug(ex);
      }
    },

    _onUploadSuccess: function(file, serverData) {
      this.notifier().success('File successfully uploaded.');
      //this.taxon().fire('update', { memo: { record: this.taxon() } });
      if (serverData.evalJSON(true).protologue_file.id){
        this.taxon().attributes().protologue = true;
      }
    },

    _onUploadStart: function () {
      this.notifier().working("<div id='divFileProgressContainer'></div>")
    },

    _onUploadComplete: function(file) {
      var notifier = this.notifier();
      /*  I want the next upload to continue automatically so I'll call startUpload here */
      if (this.swfu.getStats().files_queued > 0) {
        this.swfu.startUpload();
      }else{
        
        notifier.success("File received.");
        var html = "&nbsp;<a target='_blank' title='Click to download protologue file' href='" + this.context().routes().pathFor('get_protologue_project_taxon_path') + "'><b>Protologue File</b></a>";
            html += " | <a href='#' id='delete_protologue'>Delete File</a>";
        this.swfu.setButtonText("&nbsp;<span class='protologue_upload_link' >Change Protologue File (3 MB Max)</span>");
        $('view_protologue_link').innerHTML = html;
        
      }
      
    },
  
  _textAreaOrText: function(fieldName, value, options) {
    options || (options = {});
    var rows = options.rows || 4;
//    var cols = options.cols || 40;
    var width = options.width || 450;
    if(!value || value == 'null') {
      value = ''
      }
    var output="";//="<table id='taxon_description'><tr id='row1'>"

    switch(this.frame().interactMode().toString()) {
      case 'browse':
        //  if(!value || value.strip() == '') {
        //       value = "<span class='empty'>None</span>";
        //   }
        //   return value;
        if(value=="")
          // output+="<td class='value' colspan='3' align='center'><span class='empty'>No Description</span></td>"
          output +=  "<span class=\"empty\">None</span>";
        if(value!="")
        {
          //output+="<td align='center' class='value' colspan='3'>"+value+"</td>"
          //output+="</tr></table>
          output =  "<div class=\"value\" style=\"width:"+width+"px\">" + value + "</div>";
        }
        return output;
      case 'edit'  :
        // output+="<td align='center' class='value' colspan='3'><textarea id='taxon_#{fieldName}_textarea' name='taxon[#{fieldName}]'>#{value}</textarea>".interpolate({
        //   fieldName: fieldName,
        //  value: value
        value = value.replace(/"/g, '&quot;');
        output="<textarea id=\"taxon_#{fieldName}_textarea\" rows=\" "+rows+"\" style=\"width:"+width+ "px \" name=\"taxon[#{fieldName}]\">#{value}</textarea>".interpolate({
          fieldName: fieldName,
          value: value.replace(/<br\/>/g,"\n")
        });
        //output+="</tr></table>"
        return output;
    }
  },

  _textFieldOrText: function(fieldName, value, size, options) {
    if(!value || value == 'null') {
      value = ''
      }
    options = options || { }
    value = String(value);
    var width = options.width || 450;
    var styleOption;
    switch(this.frame().interactMode().toString())  {
      case 'browse':
        if(!value || value.strip() == '')
        {
          value = "<span class=\"empty\">None</span>";
        }
        else
        {
          if(options['link_id'])
          {
            value = "<span class=\"link\" data-taxon-id=\""+options['link_id']+"\">" + value + "</span>";
          }
          value = "<div class='value' style='width:"+width+"px'>"+value+"</div>"
        }
        return value;
      case 'edit':
        if(!value || value.strip() == '' || value == "null")
        {
          value = "";
        }
        return '<input type="text" size="#{size}" name="taxon[#{fieldName}]" value="#{value}" />'.interpolate({
          size: size,
          fieldName: fieldName,
          value: value.replace(/"/g,'&quot;'),
          styleOption: styleOption
        });
    }
  },
//     _loadImages: function() {
//        switch(this.frame().interactMode().toString()) {
//
//          case 'browse':
//                       var i
//                var output="<table id='taxon_images'><tr id='row1'>"
//                for(i=0;i<this.taxon().attributes().images.length;i++)
//                {
//                  var fname=new Array();
//                  fname=this.taxon().attributes().images[i].filename.split('.');
//                  output+="<td align='center'><a target='_blank' href='/images/0000/0"+this.taxon().attributes().images[i].id+"/"+this.taxon().attributes().images[i].filename+"'><img class='noborderimage' height='100' width='100' src='/images/0000/0"+this.taxon().attributes().images[i].id+"/"+fname[0]+"_thumb."+fname[1]+"'/></a></td>"
//                }
//                if(i==0) {
//                  output+="<td align='center'><span class='empty'>No Images</span></td>"
//                }
//                output+="</tr>"
//                  output+="<tr>"
//                    for(i=0;i<this.taxon().attributes().images.length;i++)
//                {
//                  output+="<td align='center'>"+this.taxon().attributes().images[i].caption+"</td>"
//                }
//                output+="</tr><tr>"
//                for(i=0;i<this.taxon().attributes().images.length;i++)
//                {
//                  output+="<td align='center'>"+this.taxon().attributes().images[i].photographers_credits+"</td>"
//                }
//                output+="</tr>";
//                output+="</table>";
//                    return output;
//                    break;
//
//          case 'edit':
//            var i;
//            var output="<table id='taxon_images'><tr id='row1'>";
//            for(i=0;i<this.taxon().attributes().images.length;i++)
//            {
//              var fname1=new Array();
//              fname1=this.taxon().attributes().images[i].filename.split('.');
//              output+="<td align='center'><a target='_blank' href='/images/0000/0"+this.taxon().attributes().images[i].id+"/"+this.taxon().attributes().images[i].filename+"'><img class='noborderimage' height='100' width='100' src='/images/0000/0"+this.taxon().attributes().images[i].id+"/"+fname1[0]+"_thumb."+fname1[1]+"'/></a></td>";
//            }
//            if(i==0) {
//              output+="<td align='center'><span class='empty'>No Images</span></td>";
//            }
//            output+="</tr>";
//
//            output+="<tr>"
//            for(i=0;i<this.taxon().attributes().images.length;i++)
//            {
//              var temp="";
//              if(this.taxon().attributes().images[i].caption==null)
//                temp="Enter Caption";
//              else
//                temp=this.taxon().attributes().images[i].caption;
//              output+="<td align='center'><input size='10' type='text' value='"+temp+"' name='taxon[caption]'></td>"
//            }
//            output+="</tr><tr>"
//            for(i=0;i<this.taxon().attributes().images.length;i++)
//            {
//              if(this.taxon().attributes().images[i].photographers_credits==null)
//                temp="Photographer";
//              else
//                temp=this.taxon().attributes().images[i].photographers_credits;
//              output+="<td align='center'><input size='10' type='text' value='"+temp+"' name='taxon[photographer_credits]'></td>"
//            }
//            output+="</tr>"
//            output+="</table>";
//            output+='<div style="margin: 0px 10px;"><div>';
//            output+="<input id='options_image_type' type='hidden' value='Taxon' name='options[image_type]'/>";
//            output+="<input id='options_id' type='hidden' value='"+this.taxon().id()+"' name='options[id]'/>";
//            output+='<div style="display: inline; border: solid 1px #7FAAFF; background-color: #C5D9FF; padding: 2px;">';
//            output+='<span id="spanButtonPlaceholder"></span></div></div>';
//            output+='<div id="divFileProgressContainer" style="height: 75px;"></div><div id="thumbnails"></div></div>';
//            return output;
//        }
//      },

    _loadMolecular: function() {
      //displaying dna samples
      var str='<tr><td class="taxon_dna_samples">'
      if(this.taxon().attributes().dna_samples==null || this.taxon().attributes().dna_samples.count == 0) {
        str+="<span class='empty'>  No DNA samples </span>"
      } else {
        var i     = 0
          , total = this.taxon().attributes().dna_samples.count
          , displayName, sample, url;

        str += "<ul>";
        for (i=0; i<total; i++) {
          sample = this.taxon().attributes().dna_samples.dna_samples[i].dna_sample;
          url = "/projects/"+ params['project_id'] +"/molecular/dna_samples/" + sample.id;
          displayName = (sample.sample_type ? sample.sample_type.truncate(10).toUpperCase() : "Unlisted") + ": " + ( sample.sample_nr ? ("#" + sample.sample_nr) : ("Sample " + i.toString()) );
          str += "<li><a target='_blank' href='"+url+"'>"+displayName+"</a></li>";
        }
        str += "</ul>"
      }
      str += '</td>';
      //displaying the sequences
      str += '<td class="taxon_sequences">';
      if(this.taxon().attributes().sequences.count==0) {
          str+="<span class='empty'>  No Sequences </span>"
      } else {
        var i   = 0
          , url = "";

        str+= "<ul>";
        total = this.taxon().attributes().sequences.count
        for(i=0;i<total;i++)
        {
          var seq = this.taxon().attributes().sequences.seqs[i].seq;
          var seqId = seq.id;
          var seqIdentifier = "[" + seq.markers_fulltext + "] (" + seq.sequence.truncate(10) + ")";
          var tooltip = seq.sequence.split(/(.{0,60})/).join(' ').strip();
          if(seqIdentifier == null) seqIdentifier = "";
          url = "/projects/"+ params['project_id'] +"/molecular/sequences/" + seqId;
          str += "<li><a target=\"_blank\" title=\""+tooltip+"\"  href=\""+url+"\">"+seqIdentifier+"</a></li>";
        }
        str += "</ul>"
      }
      str += '</td></tr>';
      return str;
  },

    addCitationButton: function () {
      return((this.interactMode() == 'browse') ?
        ''
      : "<input type='button' class='citation_search' value='Add Citation' />"
      )
    },

    _conStatLink: function (){
      if(this.interactMode() == "edit"){
        return "<a target='_blank' href='http://www.iucnredlist.org/technical-documents/categories-and-criteria' title='Conservation status information'>Current Conservation Status Information</a>"
      }else{
        return ""
      }
    },
    citation_item_name: function (citation) {
      return('taxon_'+this.taxon().id()+'_citation_'+citation.id)
    },


    addCitationButton: function () {
        return((this.interactMode() == 'browse') ?
            ''
            : "<input type='button' class='citation_search' value='Add Citation' />"
            )
    },

    _conStatLink: function (){
        if(this.interactMode() == "edit"){
            return "<a target='_blank' href='http://www.iucnredlist.org/technical-documents/categories-and-criteria' title='Conservation status information'>Current Conservation Status Information</a>";
        }else{
            return ""
        }
    },
    citation_item_name: function (citation) {
        return('taxon_'+this.taxon().id()+'_citation_'+citation.id)
    },

    _loadCitations: function() {
      var output;
      if(this.taxon().attributes().citations) {
        output = this.taxon().attributes().citations.citations.inject('',
  //            .sortBy(function (citation) { return (citation.contributors[0].last_name+", "+citation.contributors[0].first_name) })
          function (out, citation) {
            return out+this.context().templates().get('shared/_list_citations_taxa').evaluate({
              citation:             citation.citation,
              'raw citation_display_name(citation)': citation.citation.display_name,
              project_id:           this.params().project_id,
              taxon_id:             this.params().id,
              buttons_classes:      this.interactMode() == 'edit' ? ' active' : '',
              citation_delete:      (this.frame().interactMode() == 'browse') ? '': '<img class="delete_citation" src="/images/delete.gif" alt="delete citation" width="12px" height="12px" />',
              delete_citation_path: this.context().routes().pathFor('delete_citation_project_taxon_path', {taxon_id: this.taxon().id()})
            });
          }, this);
      }else{
        output+="<span class='empty'>  No citations </span>"
      }
      return output;
    }
     }

 });
