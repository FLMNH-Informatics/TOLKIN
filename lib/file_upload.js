function xfileUpload(form, action_url, div_id) {
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
//    id = json.fasta_filename_id;
//    count = json.count
//    me.notifier().working('Proccessing ' + count.toString() + ' sequence(s)...')
    me._frame._parent._designatedFrame._page._widgets._initial.catalog._collection.load()
  //            new Molecular.Insd.Seq({ context: me.context() }).fire('update');
//    get_seqs_from_filename(me, id, 'detailed')
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
