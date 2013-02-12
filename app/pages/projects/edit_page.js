//=require <page>

Module('Projects', function () {
  JooseClass('EditPage', {
    isa: Page,
    has: {
      savable: { is: 'ro', init: true },
      canRender: { is: 'ro', init: false },
      title:     { is: 'ro', init: 'Project Information'},
      htmlLoader:{ is: 'ro', lazy: true, init: function () {
        return $HtmlLoader({
          pathname: 'edit_project_path'
        }, this)
      }}
    },
    methods: {
      onClick: function (event) {
        var me = this;
        switch(event.element()){
            case $$('input.button[value=Save]')[0]:
                event.stop();
                var form = event.element().up('.dialog').down('.edit_project');

                form.request({
                    requestHeaders: { Accept: 'application/json' },
                    onSuccess: function (transport) {
                        me.notifier().success('Project updated.');
                        //(new Collection({ context: me.context() })).fire('create');
                        me.frame().close();
                    }
                })
                break;
            case $('project_public'):
                //$('public_license_div').toggle();
                break;
        }


      },
      onChange: function (event) {

        if (event.element() == $("project_public_license_id")){

          var c = parseInt(event.element().value);

          if(c == 0 || c > 4){
            if(c == 0){

                $('public_license_name').value = ''
                $('public_license_label').value = ''
                $('public_license_description').value = ''
                $('public_license_url').value = ''
            }else{
                new Ajax.Request('/projects/'+ID+'/license_info/'+c,{
                        method: 'get',
                        requestHeaders: { Accept: 'application/json' },
                        onSuccess: function(trans){
                            var resp = trans.responseJSON;
                            $('public_license_name').value = resp.name
                            $('public_license_label').value = resp.label
                            $('public_license_description').value = resp.desc
                            $('public_license_url').value = resp.url
                        }
                    }
                );
            }
            $('public_license_other').show();

          }else{
              $('public_license_name').value = ''
              $('public_license_label').value = ''
              $('public_license_description').value = ''
              $('public_license_url').value = ''
              $('public_license_other').hide();
          }
        }
      }
    }
  })
})