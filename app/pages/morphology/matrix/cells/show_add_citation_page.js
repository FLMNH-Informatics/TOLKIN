//= require <page>

JooseModule('Morphology.Matrix.Cells', function () {
  JooseClass('ShowAddCitationPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Citations Search' },
      htmlLoader: { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'show_add_citation_project_morphology_matrix_cell_path'
        }, this)
      } }
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
              $$('.div_citation_list')[0].innerHTML = '<img src="/images/ajax-loader-large.gif" alt="Searching..." /><br/></br>';
            }
          }
        }).bind(this)(event)
      },
      onSubmit: function (event) {
        var me = this;
        Event.delegate({
          '.citation_add': function (event) {
            event.stop();
            var fields = event.element().serialize({ hash: true, submit: false });
            if(typeof fields["citation_ids[]"] != 'undefined'){
              me.notifier().working('Adding citation(s)...');
              new Ajax.Request(me.route('citation_add_project_morphology_matrix_cell_path'), {
                requestHeaders:["Accept", "application/json"],
                parameters: fields,
                onSuccess: function (transport) {
                  me.frame().loadPage('project_morphology_matrix_cell_path', {matrix_id: params['matrix_id'], id: transport.responseJSON.cell_id});
                  me.notifier().success('Citation added.');
                },
                onFailure: function () {
                  me.notifier().error('Could not add citations to cell.');
                }
              });
            }else{
              alert('You must first select a citation');
            }
          }
        })(event);
      }
    }
  });
});
