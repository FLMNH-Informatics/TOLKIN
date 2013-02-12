//= require <page>
//= require <html_loader>

JooseModule('Molecular.Matrices', function () {
  JooseClass('EditPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      title:          { is: 'ro', init: 'Molecular Matrix : Edit' },
      width:          { is: 'ro', init: 475 },
      savable:        { is: 'ro', init: true},
      saveButtonText: { is: 'ro', init: 'Save' },
      height:         { is: 'ro', init: 150 },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'edit_project_molecular_matrix_path'
      }, this) } }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"][value="Save"]': function (event) {
            var name = $('matrix_name').value
              , description = $('timeline_description').value;
            me.notifier().working('Updating...')
            new Ajax.Request('/projects/' + params['project_id'] + '/molecular/matrices/' + params['id'] + '/update_info',{
              parameters: {name: name, description: description},
              onSuccess: function(response){
                $$('.matrix_title')[0].update(response.responseJSON.html)
                me.notifier().success('Updated.')
                me.frame().close();
              },
              onFailure: function(response){}
            })
          }
        }).call(this,event)
      }
    }
  })
});