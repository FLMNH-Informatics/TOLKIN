//= require <widget>

Module('Library.Citations', function () {
  JooseClass('AuthorsCatalogActionPanel', {
    isa: Widget,
    methods: {
      render: function () {
        return this.template('library/citations/_authors_catalog_action_panel').evaluate({
          id: this.id(),
          count_num: this.parent().selected().size() > 0 ? ''+this.parent().selected().size()+' selected' : ''
        })
      }
    }
  });
});