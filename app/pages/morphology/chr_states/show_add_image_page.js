//= require <page>

JooseModule('Morphology.ChrStates', function () {
  JooseClass('ShowAddImagePage', {
    isa: Page,
    has: {
      canRender: {is: 'ro', init: true},
      title: {is: 'ro', init: 'Morphology Character State: Add Image'},
      height: {is: 'ro', init: '70px'},
      width: {is: 'ro', init: '375px'},
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_image_project_morphology_character_chr_state_path'
      }, this)}}
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          "#attach_chr_state_image": function (event) {
            event.stop();

            var inputImageFile    = $('new_chr_state_image').down('input')
              , chrStateId        = $('new_chr_state_image').dataset.state_id
              , chrStateImageForm = $('new_chr_state_image').down('form');

              //file upload stuff
            if (inputImageFile.value != ''){
              $('attach_chr_state_image').disabled = true;

              function fileUpload(form, action_url, div_id){
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
                  var html;
                  if (iframeId.detachEvent) iframeId.detachEvent("onload", eventHandler);
                  else iframeId.removeEventListener("load", eventHandler, false);
                  $('attach_chr_state_image').disabled = false;

                  // Message from server...
                  if (iframeId.contentDocument) {
                    html = iframeId.contentDocument.body.innerHTML;
                  } else if (iframeId.contentWindow) {
                    html = iframeId.contentWindow.document.body.innerHTML;
                  } else if (iframeId.document) {
                    html = iframeId.document.body.innerHTML;
                  }
                  if (html.startsWith('Error')){
                    me.notifier().error(html.toString());
                  }else if(html.startsWith('You')){
                    me.notifier().warning(html.toString());
                  }else if(html.startsWith('<')){
                    $('chr_state_table_' + chrStateId).replace(html);
                    me.notifier().success('Image attached.')
                  }else{
                    if (!isNaN(parseFloat(html) && isFinite(html))){
                      window.location = '/projects/' + params['project_id'] + '/morphology/characters/' + html.toString();
                    }else{me.notifier().error('Somethign went wrong.')}
                  }
                  // Del the iframe...
                  setTimeout('iframeId.parentNode.removeChild(iframeId)', 250);
                  me.frame().close();

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

              me.notifier().working('Attaching image...');
              fileUpload(chrStateImageForm, window.location.pathname + '/chr_states/' + chrStateId.toString() +  '/attach_image', 'upload');
            }else{me.notifier().warning('You must choose a file')}
          }
        }).bind(this)(event)
      },
      onSubmit: function (event) {
        var me = this;
        Event.delegate({
        }).bind(this)(event)
      }
    }
  })
})