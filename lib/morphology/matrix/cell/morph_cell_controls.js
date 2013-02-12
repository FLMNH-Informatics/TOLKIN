JooseRole('MorphCellControls', {
  methods: {
    onClick: function (event) {
      var me = this;
      Event.delegate({
        '.show_image': function (event){ me.frame().loadPage('image_path', {id: event.element().readAttribute('data-image-id')})},
        '.remove_image_from_cell': function (event){
          if (confirm('Do you want to remove the image?')){
            var imageId = event.element().dataset.imgId;
            me.notifier().working('Removing image...')
            new Ajax.Request('/projects/' + params['project_id'] + '/morphology/matrices/' + params['matrix_id'] + '/cells/' + params['id'] + '/remove_image?image_id=' + imageId, {
              responseType: {accept: 'application/json'},
              onSuccess: function(response){
                var json = response.responseJSON;
                var cell = json.cell
                var td = new Element('td', {
                  id:             cell.td_id,
                  'class':        cell.class_name,
                  'data-cell-id': cell.data_cell_id.toString()
                }).update(json.cell.innerHTML);
                $(cell.td_id).replace(td);
                $('image_' + imageId).innerHTML = "";
                params['id'] = json.cell_id;
                me.notifier().success('Image removed.')
              },
              onFailure: function(){me.notifier().error('Something went wrong')}
            })
          }
        },
        '.unselected': function (event){
          event.stop();
          var unselectedDiv = $$('.morphology_unselected')[0]
            , selectedDiv   = $$('.morphology_selected')[0]
            , unselectedSpan = $$('.unselected.head')[0]
            , selectedSpan  = $$('.selected.head')[0];
          selectedSpan.toggleClassName('selected');
          selectedSpan.toggleClassName('unselected');
          unselectedSpan.toggleClassName('selected');
          unselectedSpan.toggleClassName('unselected');
          unselectedDiv.toggleClassName('morphology_unselected');
          selectedDiv.toggleClassName('morphology_selected');
          unselectedDiv.toggleClassName('morphology_selected');
          selectedDiv.toggleClassName('morphology_unselected');
        },
        '.add_citation': function (event) {
          me.frame().viewport().widgets().get('window').loadPage('show_add_citation_project_morphology_matrix_cell_path', {id: params['id'], matrix_id: params['matrix_id']})
        },
        'button.citation_edit':  function(event){
          event.stop();
          var citationId = event.element().readAttribute('data-citation-id');
          me.frame().loadPage('project_library_citation_path', {id: citationId, project_id: params['project_id']})
        },
        'button.citation_remove': function(event){
          if (confirm('Are you sure you would like to remove this citation?')){
            me.notifier().working('Removing citation...');
            var citationId = event.element().dataset.citationId;
            new Ajax.Request('/projects/' + params['project_id'] + '/morphology/matrices/' + params['matrix_id'] + '/cells/' + params['id'] + '/remove_citation?citation_id=' + citationId, {
              responseType: {accept: 'application/json'},
              onSuccess: function(response){
                var json = response.responseJSON;
                var cell = json.cell
                var td = new Element('td', {
                  id:             cell.td_id,
                  'class':        cell.class_name,
                  'data-cell-id': cell.data_cell_id.toString()
                }).update(json.cell.innerHTML);
                $(cell.td_id).replace(td);
                event.element().up('div').up('div').remove();
                params['id'] = json.cell_id;
                me.notifier().success('Citation removed.')
              }
            })
          }
        },
        'input[type="button"].saveButton': function (event) {
          me.notifier().working('Updating cell...')
          $$('input[type="button"].saveButton')[0].disable();
          fileUpload($$('form')[0], '/projects/' + params['project_id'] + '/morphology/matrices/'+ params['matrix_id'] + '/cells', 'upload')
          $$('input[type="button"].saveButton')[0].enable();

          function fileUpload(form, action_url, div_id) {
            // Create the iframe...
            var iframe = document.createElement("iframe");
            iframe.setAttribute("id", "upload_iframe");
            iframe.setAttribute("name", "upload_iframe");
            iframe.setAttribute("width", "0");
            iframe.setAttribute("height", "0");
            iframe.setAttribute("border", "0");
            iframe.setAttribute("style", "width: 0; height: 0; border: none;");

            // Add to document...
            form.parentNode.appendChild(iframe);
            window.frames['upload_iframe'].name = "upload_iframe";

            iframeId = document.getElementById("upload_iframe");

            // Add event...
            var eventHandler = function () {
              var json, cell;
              if (iframeId.detachEvent) iframeId.detachEvent("onload", eventHandler);
              else iframeId.removeEventListener("load", eventHandler, false);

              // Message from server...
              if (iframeId.contentDocument) {
                json = iframeId.contentDocument.body.innerHTML.evalJSON()
              } else if (iframeId.contentWindow) {
                json = iframeId.contentWindow.document.body.innerHTML.evalJSON();
              } else if (iframeId.document) {
                json = iframeId.document.body.innerHTML.evalJSON();
              }

              cell = json.cell;
              me.notifier().success(json.msg);
              var td = new Element('td', {
                id:             cell.td_id,
                'class':        cell.class_name,
                'data-cell-id': cell.data_cell_id.toString()
              }).update(json.cell.innerHTML);
              $(cell.td_id).replace(td);
              // Del the iframe...
              setTimeout('iframeId.parentNode.removeChild(iframeId)', 250);
              $$('input[type="button"].saveButton')[0].enable();
              me.frame().loadPage("project_morphology_matrix_cell_path", {matrix_id: params["matrix_id"], id: json.cell.data_cell_id.toString()})

            }
            if (iframeId.addEventListener) iframeId.addEventListener("load", eventHandler, true);
            if (iframeId.attachEvent) iframeId.attachEvent("onload", eventHandler);

            // Set properties of form...
            form.setAttribute("target", "upload_iframe");
            form.setAttribute("action", action_url);
            form.setAttribute("method", "post");
            form.setAttribute("enctype", "multipart/form-data");
            form.setAttribute("encoding", "multipart/form-data");

            // Submit the form...
            form.submit();

            document.getElementById(div_id).innerHTML = "Uploading...";
          }

        }
      }).call(this,event)
    }
  }
})