//= require <widget>
//= require <templates/window>

Module('Molecular.DnaSamples', function () {
  JooseClass('UserPanel', {
    isa: Widget,
    methods: {
      onClick: function (event) {
        Event.delegate({
          'li': function (event) {
            switch(event.element().innerHTML) {
              case 'New Raw DNA':
                var queue = new Queue();
                var window = this.viewport().widgets().get('window');
                queue.join(window.loadPage('new_project_dna_sample_path', { queue: queue, render: false }));
                queue.add(function () {
                  window.page().loadContents({onSuccess: function () {
                    window.render().show();
                  }});
                });
                queue.flush();
            }
          }
        }).bind(this)(event)
      }
    }
  })
});