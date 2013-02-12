//= require <page>

JooseModule('Morphology.Characters', function () {
  JooseClass('ShowAddCitationPage', {
    isa: Page,
    has: {
      canRender: {is: 'ro', init: true},
      title: {is: 'ro', init: 'Morphology Character: Add Citation'},
      htmlLoader: { is: 'ro', init: function () { return $HtmlLoader({
        pathname: 'show_add_citation_project_morphology_character_path'
      }, this)}}
    },
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
          '*[value="Create Citation"]': function (event) {
            me.frame().loadPage('new_project_library_citation_path');
          },
          '*[name="commit"]': function (event) {
            if (!event.element().up('form').hasClassName('citation_add')){
              $$('.div_citation_list')[0].innerHTML = '<img src="/images/ajax-loader-large.gif" alt="Searching..." /><br/><br/>';
            }
          }
        }).bind(this)(event)
      },
      onSubmit: function (event) {
        var me = this;
        Event.delegate({
          '.citation_add': function (event) {
            event.stop();
            me.notifier().working('Adding citation(s)...');
            var fields = event.element().serialize({ hash: true, submit: false });
            var path   = window.location.pathname  + '/citation_add';
            if (typeof fields["citation_ids[]"] != 'undefined'){
              new Ajax.Request(path, {
                requestHeaders: ['Accept', 'application/json'],
                parameters: fields,
                onSuccess: function (transport) {
                  if (transport.responseJSON.msg.startsWith('Err')){
                    me.notifier().error(transport.responseJSON.msg.toString());
                  }else if (transport.responseJSON.msg == 'old'){
                    $('character_citations').replace(transport.responseJSON.partial);
                    me.notifier().success('Citation added.');
                  }else if (transport.responseJSON.msg.startsWith("You")){
                    me.notifier().warning(transport.responseJSON.msg);
                  }else if (transport.responseJSON.msg == "ok"){
                    me.notifier().error('something went wrong')
                  }else{
                    window.location = '/projects/' + params['project_id'] + '/morphology/characters/' + transport.responseJSON.msg.toString();
                  }
                }
              })
            }else{me.notifier().warn('You must first select at least one citation.')}
          }
        }).bind(this)(event)
      }
    }
  })
})