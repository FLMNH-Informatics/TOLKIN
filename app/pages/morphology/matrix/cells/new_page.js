//= require <page>
//= require <html_loader>

Module('Morphology.Matrix.Cells', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      width: { is: 'ro', init: 475 },
      savable: { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Create' },
      canRender: { is: 'ro', init: true },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_morphology_matrix_cell_path'
      }, this )}},
      title: { is: 'ro', init: 'Morphology Matrix Cell: New'},
      otuId: { is: 'rw', init: null },
      characterId: { is: 'rw', init: null}
    },
    after: {
      onLoad: function(){
        var ids = params['extraParams'].toQueryParams();
        this.setOtuId(ids.otuId);
        this.setCharacterId(ids.charId);
      }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"].saveButton': function (event) {
            me.notifier().working('Updating...');
            $$('input[type="button"].saveButton')[0].disable();
            fileUpload($$('form')[0], '/projects/' + params['project_id'] + '/morphology/matrices/'+ params['matrix_id'] + '/cells', 'upload')
          }
        }).call(this, event);

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
    }
  })
})