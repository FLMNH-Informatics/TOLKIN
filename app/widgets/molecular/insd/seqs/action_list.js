JooseModule('Molecular.Insd.Seqs', function () {
  JooseClass('ActionList', {
    isa: Widget,
    has: {
      catalog: { is: 'rw' }
    },
    methods: {
      onClick: function (event) {
        if(event.element && event.element()) {
          switch(event.element().innerHTML) {
            case 'Export DNA Sequence':
              new Ajax.Request(this.route('show_genbank_form_project_sequences_path'),{
                parameters: {
                  conditions: this.catalog().selected().toString()
                },
                method: 'get'
              })
          }
        }
      }
    }
  });
});