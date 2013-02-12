//= require <page>
//= require <html_loader>

JooseModule('Molecular.Matrices', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      canRender:      { is: 'ro', init: true },
      title:          { is: 'ro', init: 'Molecular Matrix : New' },
      width:          { is: 'ro', init: 475 },
      savable:        { is: 'ro', init: true},
      saveButtonText: { is: 'ro', init: 'Create' },
      height:         { is: 'ro', init: 150 },
      htmlLoader:     { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'new_project_molecular_matrix_path'
      }, this) } }
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          'input[type="button"][value="Create"]': function (event) {
            var name = $$('input[name="matrix[name]"]')[0].value
              , description = $$('textarea[name="timeline[description]"]')[0].value;
            me.notifier().working('Creating...')
            new Ajax.Request('/projects/' + params['project_id'] + '/molecular/matrices/',{
              parameters: {name: name, description: description},
              onSuccess: function(response){window.location = window.location.pathname + '/' + response.responseJSON.id},
              onFailure: function(response){me.notifier().error('Problem creating matrix')}
            })
          }
        }).call(this,event)
      }
    }
  })
});