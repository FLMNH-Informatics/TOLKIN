//= require <widget>
//= require <widgets/templates/window>

Module('Widgets.Molecular.Alignments', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    methods: {
      onClick: function (event) {
        Event.delegate({
          'li': function (event) {
            switch(event.element().innerHTML) {
              case 'New Alignment':
                //var queue = new Queue();
                var window = this.viewport().widgets().get('window');
                window.loadPage('new_project_alignment_path');
                window.on('state:pageRendered', window.show.bind(window), { once: true })
                //queue.add(window.show.bind(window));
                //queue.flush();
            }
          }
        }).bind(this)(event)
      }
    }
  })
});
