//= require <page>
//= require <person>
//= require <library/author>
//= require <roles/polling>
//= require <library/citations/authors_catalog>
//= require <library/citation>
//= require <library/citations/forms_helper>
//= require <library/citations/series_title_auto_text_field>
//= require <library/citations/book_title_auto_text_field>
//= require <library/citations/journal_title_auto_text_field>
//= require <library/citations/publisher_name_auto_text_field>

JooseModule('Library.Citations', function () {
  JooseClass('ShowPage', {
    isa: Page,
    does: [ Polling, Library.Citations.FormsHelper ],
    has: {
      canRender: { is: 'ro', init: true },
      width: { is: 'ro', init: 840 },
      title: { is: 'ro', init: 'Citation : Show' },
      savable: { is: 'ro', init: true },
      records: { is: 'ro', lazy: true, init: function () { return $Records({
        citation: new Library.Citation({ id: this.params().id, context: this.context() })
      }, this) } },
      htmlLoader: { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'project_library_citation_path',
          paramFunc: function () {
            return {
              interact_mode: this.interactMode().get(),
              noJSON: 'true'
            }
          }
        }, this)
      } },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        authorsCatalog: new Library.Citations.AuthorsCatalog({
          parent: this.frame(),
          authors: Library.Author.collection({
            context: this.context(),
            initLoader: this.record('citation'),
            initLoaderFn: function (atts) {
              return ({
                count: atts.contributorships.count,
                authors: atts.contributorships.contributorships.collect(function (cship) { return cship.contributorship.author })
              })
            },
            finderOptions: {
              select: [ 'id', 'name' ],
              conditions: SyncRecord.attr('contributorships.citation_id').eq(this.record('citation').id()),
              joins: 'contributorships',
              order: 'name'
            }
          })
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
      }, this ) } },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'library/citations/_authors_catalog_action_panel'
      ], this) } }
    },
    after: {
      onLoad: function () {
        if (!$$('input[type="submit"]').empty() && params["action"] == "index") $$('input[type="submit"]').first().hide();
      }
    },
    methods: {
//      onLoad: function () {
//        var me = this;
//        new Ajax.Request(this.route('project_library_citation_path'), {
//          method: 'get',
//          requestHeaders: {
//            Accept: 'text/html'
//          },
//          parameters: {
//            interact_mode: this.interactMode().get() ,
//            noJSON: 'true'
//          },
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
        this.notifier().success('Citation successfully updated.');
        this.record('citation').fire('update', { memo: { record: this.record('citation') } }); // have to fire event before page reloads and all record event listeners are expired
        if (this.context().viewport().designatedFrame().page().toString() == 'a Morphology.Characters.ShowPage'){
          window.location = window.location;
        }else{
          this.frame().reloadPage();
        }
      },

      onSubmitFailure: function () {
        this.notifier().error('Error encountered updating citation.');
      },

      onSubmitTimeout: function () {
        this.notifier().error('Timeout while updating citation.');
      }
    }
  });
});
