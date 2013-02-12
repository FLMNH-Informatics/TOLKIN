//= require <page>
//= require <person>
//= require <html_loader>
//= require <library/author>
//= require <roles/polling>
//= require <library/citations/authors_catalog>
//= require <library/citation>
//= require <library/citations/forms_helper>
//= require <library/citations/series_title_auto_text_field>
//= require <library/citations/book_title_auto_text_field>
//= require <library/citations/journal_title_auto_text_field>
//= require <library/citations/author_name_auto_text_field>
//= require <library/citations/publisher_name_auto_text_field>

JooseModule('Library.Citations', function () {
  JooseClass('NewPage', {
    isa: Page,
    does: [ Polling, Library.Citations.FormsHelper ],
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Create New Citation' },
      width: { is: 'ro', init: 800 },
      records: { is: 'ro', lazy: true, init: function () { return $Records({
            citation: new Library.Citation({ context: this.context(), data: {} })//,
            //authors: Library.Author.collection({ context: this.context() }).where(false)
      }, this) } },
      htmlLoader: { is: 'ro', init: function () {
          return $HtmlLoader({
            pathname: 'new_project_library_citation_path'
          }, this)
      } },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        authorsCatalog: new Library.Citations.AuthorsCatalog({
          parent: this.frame(),
          authors: Library.Author.collection({ context: this.context(), data: {authors: [], count: 0}}).where(false)//this.records().get('authors')
        }),
        bookTitleField: new Library.Citations.BookTitleAutoTextField({
          object: this.record('citation'),
          parent: this.frame()
        }),
        seriesTitleField: new Library.Citations.SeriesTitleAutoTextField({
          object: this.record('citation'),
          parent: this.frame()
        }),
        journalTitleField: new Library.Citations.JournalTitleAutoTextField({
          object: this.record('citation'),
          parent: this.frame()
        }),
        authorNameField: new Library.Citations.AuthorNameAutoTextField({
          object: this.record('citation'),
          parent: this.frame()
        }),
        publisherNameField: new Library.Citations.PublisherNameAutoTextField({
          object: this.record('citation'),
          parent: this.frame()
        })
      }, this) } }
    },
    methods: {
      onClickSelect: function (event) {
        var me = this;
        new Ajax.Request(this.route('new_two_project_library_citations_path'), {
          method: 'get',
          requestHeaders: { Accept: 'text/html' },
          parameters: {
            citation_type: $F($(me.frame().id()).down('#select_new_citation_type')),
            interact_mode:  me.interactMode().toString()
          },
          onSuccess: function(transport) {
            $(me.frame().id()).down('#div_create_new_citation').update(transport.responseText);
            me.frame().showSaveButton();
          }
        });
      },

//      onLoad: function () {
//        var me = this;
//        new Ajax.Request(this.route('new_project_library_citation_path'), {
//          method: 'get',
//          parameters: { interact_mode: me.interactMode().toString() },
//          requestHeaders: { Accept: 'text/html' },
//          onSuccess: function (transport) {
//            me._rendered = transport.responseText;
//            me.state().set('loaded');
//          }
//        });
//      },

//      render: function () {
//        return this._rendered;
//      },

      onSubmitSuccess: function () {
        var citation = new Library.Citation({ context: this.context() });
        citation.fire('create', { memo: { record: citation } });
        this.notifier().success('Citation successfully created.');
        this.frame().back();
      },

      onSubmitFailure: function () {
        this.notifier().error('Error encountered creating citation.');
      },

      onSubmitTimeout: function () {
        this.notifier().error('Timeout while creating citation.');
      }
    }
  });
});
