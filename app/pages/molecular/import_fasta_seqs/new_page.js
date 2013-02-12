//= require <page>
//= require <html_loader>
//= require <molecular/insd/seq>
JooseModule('Molecular.ImportFastaSeqs', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      title:          { is: 'ro', init: 'Upload Sequences' },
      canRender:      { is: "ro", init: true },
      savable:        { is: 'ro', init: true },
      saveButtonText: { is: 'ro', init: 'Upload' },
      height:         { is: 'ro', init: 300 },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_molecular_import_fasta_seq_path'
      }, this ) } },
      seqIds: { is: 'rw'},
      fastaFilename: { is: 'rw' },
      fastaFilenameId:{ is: 'rw' },
      records: { is: 'ro', lazy: true, init: function () {
        return $Records({
          seq: new Molecular.Insd.Seq({ context: this.context() })
        }, this)}
      },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
                  taxonNameField: new Molecular.Insd.Seqs.TaxonNameAutoTextField({
                    object: this.record('taxon'),
                    parent: this.frame()
                  })}, this)
              }
      }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"].saveButton': function  () {
            if ($('seq_uploaded_data').value != ""){
              me.notifier().working('Uploading fasta file...')
              $$('input[type="button"].saveButton')[0].disable()
              fileUpload($$('form')[0], '/projects/' + params["project_id"] + '/molecular/import_fasta_seqs', 'upload')
              $$('input[type="button"].saveButton')[0].enable();
            }else{
              me.notifier().warning('You must select a file to process.')
            }
          }
        }).call(this, event)
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
            var json, id, count;
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
            id = json.fasta_filename_id;
            count = json.count
            me.notifier().working('Proccessing ' + count.toString() + ' sequence(s)...')
            me._frame._parent._designatedFrame._page._widgets._initial.catalog._collection.load()
//            new Molecular.Insd.Seq({ context: me.context() }).fire('update');
            get_seqs_from_filename(me, id, 'detailed')
//                  document.getElementById(div_id).innerHTML = content;

              // Del the iframe...
              setTimeout('iframeId.parentNode.removeChild(iframeId)', 250);
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