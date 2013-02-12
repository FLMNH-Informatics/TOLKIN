//= require <page>
JooseModule('Chromosome.ZFiles', function () {
  JooseClass('ShowPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: false },
      title:     { is: 'ro', init: 'Assign Probe to ZVI File'},
      savable:   { is: 'ro', init: true },
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'project_chromosome_z_file_path'
      }, this)}}
    },
    methods: {
      validateEdit: function (fn) {
        if(this.interactMode()._value == 'edit'){ fn(); }
        else{ this.notifier().warn('You must be in edit mode to complete this action'); }
      },
      verify: function (msg,fn) { if (confirm("Are you sure you want to " + msg)) fn(); },
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '#assign_probe': function (event) { me.validateEdit( function(){
              me.frame().viewport().widget('window').loadPage('show_add_probe_project_chromosome_z_file_path');
            })
          },
          '.remove_probe': function (event) { me.validateEdit( function(){
            me.verify("remove this hybridization/probe?", function () {
              var hybridizationId = event.element().up('tr').dataset.hybridizationId;
              me.notifier().working('Removing probe...');
              new Ajax.Request(me.context().routes().pathFor('remove_hybridization_project_chromosome_z_file_path'), {
                method: 'put',
                parameters: { 'hybridization_id': hybridizationId.toString() },
                requestHeaders: ['Accept', 'application/json'],
                onSuccess: function(transport){
                  var msg = transport.responseJSON.msg;
                  if (msg.startsWith('Err')){
                    me.notifier().error(msg.toString());
                  }else{
                    event.element().up('tr').remove();
                    me.notifier().success('Hybridization/Probe removed from ZVI File.');
                  }
                }
              })
            })
          })},
          'input[type="submit"][value="Upload"]': function (event) { me.validateEdit( function () {
              event.stop();
              if ($("chromosome_z_file_image").files.length > 0){
                me.notifier().working('Uploading image...')
                event.element().up('form').submit();
              }else{
                me.notifier().warning('You must choose a file to upload.');
              }
          })},
          '.remove_image': function (event){
            me.validateEdit( function () {
              me.verify("remove this image?", function () {
                var imgId = event.element().dataset.imgId;
                me.notifier().working('Removing image...');
                new Ajax.Request(me.context().routes().pathFor('remove_image_project_chromosome_z_file_path'), {
                  method:         'delete',
                  parameters:     {"image_id": imgId.toString()},
                  requestHeaders: ['Accept', 'application/json'],
                  onSuccess: function (transport) {
                    event.element().up('div.img_holder').remove();
                    me.notifier().success('Image removed from ZVI File.');
                  }
                })
              })
            })
          }
        }).call(this,event)
      }
    }
  })
})