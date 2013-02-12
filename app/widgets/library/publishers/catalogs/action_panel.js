//= require <widgets/templates/tooltip>
//= require <widget>


Module('Widgets.Library.Publishers.Catalogs', function () {
  JooseClass('ActionPanel', {
    isa: Widget,
    has:{
        collection_view: { is: 'ro', init: function () { return this.parent() } }
    },
//    after: {
//      initialize: function () {
//        this.parent().after({ initialize: function () {
//          this.parent().selected().channel('me:widgets').addListener(this);
//        }}, this)
//      }
//    },
    methods: {
      renderToString: function () {
        return this.context().templates().get('library/publishers/catalogs/_action_panel').evaluate({
          id: this.id(),
          count_num: this.parent().selected().size()+' selected'
        })
      },

     

      onClick: function(event) {
        Event.delegate({
          '#create':function(event){
//                new Ajax.Request("/projects/" + params['project_id'] + "/publishers/new", {
//                  method: 'get'
//                });
                window.location = "http://localhost:3000"+"/projects/" + params['project_id'] + "/publishers/new"
          },
          '#delete':function(event){
            var hasConfirmed = confirm('Are you sure you would like to delete the selected publishers?');
            if(hasConfirmed) {
                form = $('list_items_form')
                form.writeAttribute('action', '/projects/'+params['project_id']+'/publishers/delete_selected');
                form.writeAttribute('method', 'post');
                document.getElementById('list_items_form').submit();
              }
          }
        }).bind(this)(event);
      }
    }
  })
});
