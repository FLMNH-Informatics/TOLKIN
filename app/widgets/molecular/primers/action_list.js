//= require <widget>
//= require <molecular/primer>
Module('Widgets.Molecular.Primers', function () {
  JooseClass('ActionList', {
    isa: Widget,
    methods: {
      onClick: function (event) {
        var me = this;
        Event.delegate({
        'li': function (event) {
//          alert('hello')
         switch(event.element().innerHTML)
        {
          case "New Primer":
            var window = this.viewport().widgets().get('window');
            window.loadPage('new_project_primer_path');
            window.show();
//            var primerDetailsWindow = new TOLKIN.views.molecular.primer._Window({  context : me.context(), parent : me.viewport(), primer : new TOLKIN.model.Primer({context : me.context()})});
//              primerDetailsWindow.loadContents({
//                onSuccess: function () { primerDetailsWindow.render().show() }
//                 });
                 break;
          
         }
        }
      }).bind(this)(event)
      }
    }
       
  })
});