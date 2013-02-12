//= require <page>
//= require <taxa_helper>
//= require <taxa/tabbed_box>
//= require <taxa/taxon_outlinks_table>
//= require <taxa/accepted_name_combo_box>
//= require <taxon>
//= require <roles/polling>

Module('Taxa', function() {
  JooseClass('ShowPage', {
    isa: Page,
    does: [TaxaHelper, Polling],
    has: {
      canRender: { is: 'ro', init: true },
      width:  { is: 'ro', init: 790 },
      height: { is: 'ro', init: null },
      title:  { is: 'ro', init: 'Taxon : Show' },
      savable: { is: 'ro', init: true },
      records: { is: 'ro', lazy: true, init: function () { return($Records({
        taxon: new Taxon({ id: this.context().params().id, context: this.frame().context()})
      }, this))}},
      widgets: { is: 'ro', lazy: true, init: function () { return $WSet({
        tabbedBox:
          new Taxa.TabbedBox({
            taxon: this.record('taxon'),
            parent: this.frame(),
            context: this.context(),
            frame: this.frame()
          }),
        acceptedNameComboBox:
            new Taxa.AcceptedNameComboBox({
              parent: this.frame(),
              context: this.context(),
              taxon: this.records().get('taxon')
            })
      }, this)}},
      templates: { is: 'ro', lazy: false, init: function () { return $TSet([
          'forms/_date_field',
          'collections/show',
          'widgets/_combo_box',
          'widgets/_catalog',
          'widgets/catalogs/_entry',
          'taxa/show',
          'shared/_list_citations_taxa'
      ], this)}}
    },
    after: {
      initialize: function() {
        params['taxon_id'] = params['id'];
        this.handlers().push(
          this.frame().on('state:displayed', function () {
            this.iMode().on('state:loaded', function () {
              this._protologueOutput()
            }, { once: true }, this)
          }, this)
        )
      }
    },
    methods: {
        taxon: function () { return this.records().get('taxon') },
        tabbedBox: function () { return this.widgets().get('tabbedBox'); },
        onClick: function (event) {
          var me = this;
          Event.delegate({
            '.saveButton.active': function (event) {
               var form = event.element().up('.dialog').down('.species_page_form');
                if(form.readAttribute('class') == 'species_page_form') {
                  event.stop();
                  var formData = $$('.species_page_form').inject({}, function (out, form) {
                    return(
                      Object.extend(
                        out,
                        form.serialize({ hash: true, submit: false }))
                      )
                  }, this)
                  var me = this;
                  this.context().notifier().working('Saving ...');
                  new Ajax.Request(form.readAttribute('action'), {
                    method: form.readAttribute('method'),
                    parameters: formData,
                    requestHeaders: { Accept: 'application/json' },
                    onSuccess: function(transport) {
                      me.records().get('taxon').update(Object.values(transport.responseJSON).first(), { request: false });
                      me.context().notifier().success('Saved.');
                      //window.location.reload(true); // force page refresh for now - TODO - update page appropriately with message / event passing
                    }
                  })
                }

              },
            'span.link' : function (event) {
              params['id'] = event.element().readAttribute('data-id');
              var frame = me.frame();
              var queue = new Queue();
              queue.join(
                frame.loadPage('project_taxon_path', { id: params['id'], queue: queue }));
              queue.add(
                frame.show.bind(frame) );
            },
            '#delete_protologue' : function (event){
               me = this;
               if(confirm('Delete Protologue File?')){
                 new Ajax.Request (this.context().routes().pathFor('delete_protologue_project_taxon_path'), {
                   method : 'delete',
                   onLoading: function(){
                     me.notifier().working('Deleting file.');
                   },
                   onSuccess: function(response){
                     me.notifier().success('File deleted.');
                     //me.taxon().fire('update', { memo: { record: me.taxon() } });
                     me.taxon().attributes().protologue = false
                     me.swfu.setButtonText("&nbsp;<span class='protologue_upload_link' >Add Protologue File (3 MB Max)</span>");
                     $('view_protologue_link').innerHTML = '';
                   }
                 });
               }
            }
          }).bind(this)(event)
        },

        // handle split-form situation on species page - submit all 'species_page_form' forms as one form
        onSubmit: function (event) {
          var form = event.element();
          if(form.readAttribute('class') == 'species_page_form') {
            event.stop();
            var formData = $$('.species_page_form').inject({}, function (out, form) {
              return( 
                Object.extend(
                  out,
                  form.serialize({ hash: true, submit: false }))
                )
            }, this)
            var me = this;
            this.context().notifier().working('Saving ...');
            new Ajax.Request(form.readAttribute('action'), {
              method: form.readAttribute('method'),
              parameters: formData,
              requestHeaders: { Accept: 'application/json' },
              onSuccess: function(transport) {
                me.records().get('taxon').update(Object.values(transport.responseJSON).first(), { request: false });
                me.context().notifier().success('Saved.');
                //window.location.reload(true); // force page refresh for now - TODO - update page appropriately with message / event passing
              }
            })
          }
        },

        renderToString: function() {
          var attrs = this.taxon().attributes();
          var object = {
          taxon                                             : this.taxon().attributes(),
          "raw editors"                                     : this._textFieldOrText('editors', this.taxon().attributes().editors,54),
          "header"                                          : this._header(),
          "raw name"                                        : this._name(),
          "raw status"                                      : this._namestatusSelect(),
          "synonyms_table"                                  : ((this.record('taxon').attributes().synonyms.count < 1) ? "None<span style='display:none'>" : "<span>")+this.widget('tabbedBox').widget('synonymsCatalog').renderToString()+"</span>",
          "form_action"                                     : this.route('project_taxon_path'),
          "tabbed_box_id"                                   : this.widgets().get('tabbedBox').id(),
          publication_name                                  : this._textFieldOrText('publication', this.taxon().attributes().publication, 58),
          "text_field_or_text('volume_num',5)"              : this._textFieldOrText('volume_num', this.taxon().attributes().volume_num,5),
          "raw text_field_or_text('basionym',68)"           : this._textFieldOrText('basionym', this.taxon().attributes().basionym, 66),
          "text_field_or_text('pages',5)"                   : this._textFieldOrText('pages', this.taxon().attributes().pages,5),
          "text_field_or_text('ncbi_id',10)"                : this._textFieldOrText('ncbi_id', this.taxon().attributes().ncbi_id,10,{image_link: '<a><img class=\'ncbi\' src=\'/images/ncbiLogo.GIF\' ></img></a>'}),
          "text_field_or_text('ubio_id',10)"                : this._textFieldOrText('ubio_id', this.taxon().attributes().ubio_id,10,{image_link: '<a><img class=\'ubio\' src=\'/images/ubioLogo.png\' ></img></a>'}),
          "text_field_or_text('publication_date',5)"        : this._textFieldOrText('publication_date', this.taxon().attributes().publication_date,5),
          "text_field_or_text('infra_name',10)"             : this._textFieldOrText('infra_name', this.taxon().attributes().infra_name, 10),
          "text_field_or_text('infra_author',10)"           : this._textFieldOrText('infra_author', this.taxon().attributes().infra_author,10),
          "raw type_species"                                : this._textFieldOrText('type_species', this.taxon().attributes().type_species,65),
          "raw type_collection"                             : this._textFieldOrText('type_collection', this.taxon().attributes().type_collection,65),
          "raw type_locality"                               : this._textFieldOrText('type_locality', this.taxon().attributes().type_locality,65),
          "raw type_date"                                   : this._textFieldOrText('type_date', this.taxon().attributes().type_date,30),
          "raw type_herbaria"                               : this._textAreaOrText('type_herbaria', attrs.type_herbaria, { rows: 2, width: 617 }),
          "raw neotype"                                     : this._textFieldOrText('neotype', this.taxon().attributes().neotype,65),
          "raw common_names"                                : this._textAreaOrText('commonname', this.taxon().attributes().commonname, { rows: 4, width: 625 }),
          "raw chromosome_number"                           : this._textFieldOrText('chromosome_number', this.taxon().attributes().chromosome_number,50),
          "raw uses"                                        : this._textAreaOrText('uses', this.taxon().attributes().uses, { rows: 3, width: 450 }),
          "raw toxicity"                                    : this._textFieldOrText('toxicity', this.taxon().attributes().toxicity,50),
          "raw conservation_status"                         : this._textAreaOrText('conservation_status', attrs.conservation_status, { rows: 2, cols: 55 }),
          "raw text_field_or_text('sub_genus',15)"          : this._textFieldOrText('sub_genus', this.taxon().attributes().sub_genus,15),
          "raw text_field_or_text('section',15)"            : this._textFieldOrText('section', this.taxon().attributes().section,15),
          "raw text_field_or_text('subsection',15)"         : this._textFieldOrText('subsection', this.taxon().attributes().subsection,15),
          "raw text_field_or_text('ingroup_clade',10)"      : this._textFieldOrText('ingroup_clade', this.taxon().attributes().ingroup_clade,10),
          "text_field_or_text('volume',10)"                 : this._textFieldOrText('volume_num', this.taxon().attributes().volume_num,10),
          "raw phylogenetic_relationship"                   : this._textAreaOrText('phylogenic_relationship', attrs.phylogenic_relationship, {rows: 3, width: 450}),
          "raw general_distribution"                        : this._textAreaOrText('general_distribution', attrs.general_distribution, {rows:5, width: 675}),
          "raw molecular_data"                              : this._loadMolecular(),
          "raw citations_data"                              : this._loadCitations(),
          "raw description"                                 : this._textAreaOrText('description', attrs.description, { rows: 7, cols: 55 }),
          "raw habitat"                                     : this._textAreaOrText('habitat', attrs.habitat, { rows: 3, cols: 55 }),
          "raw comments"                                    : this._textAreaOrText('comments', attrs.comments, { rows: 4, cols: 55 }),
          "raw con_stat_link"                               : this._conStatLink(),
          "raw notes_section"                               : this.notesSection(),
          "collections_catalog"                             : this.widgets().get('tabbedBox').widgets().get('collectionsCatalog').renderToString(),
          "raw images"                                      : this.widgets().get('tabbedBox').widgets().get('imageGallery').renderToString(),
//          parent_combo_box                                  : this.widgets().get('parentComboBox').renderToString(),
          "taxon_id"                                        : "div_taxon_"+this.taxon().id()+"_citations",
          "raw add_citation_button"                         : this.addCitationButton(),
	  "raw accepted_name_combo_box"                     : this.widgets().get('acceptedNameComboBox').render(),
          accepted_name_display                             : (this.taxon().attributes().namestatus && this.taxon().attributes().namestatus.status == 'synonym') ? '' : 'display: none',
          "raw outlinks"                                    : this.widgets().get('tabbedBox').widgets().get('taxonOutlinksTable').renderToString()
        };
        object["is_selected('"+this.tabbedBox().currentTab()+"')"] = 'selected';
        var content = this.frame().templates().get('taxa/show').evaluate(object);
        //this.frame().render({ yield: content });
        //this.tabbedBox().postRender();
//        //        $('contents').down('.species_page_form').update(contents);
//
//        this._map = new OpenLayers.Map('geomap');
//        this._initMap(this._map);
//        if(this.frame().interactMode() == 'edit')
//        {
//         this._initializeSWFUpload();
//        }
        return content;
      },

//      postRender: function () {
//        this.poll({
//          on: function () { return this.context().interactMode().get() },
//          run: function () {
//            this._protologueOutput()
//          }
//        })
//        this.tabbedBox().postRender()
//      },

      notesSection: function () {
        if (this.taxon().attributes().notes === undefined) {
          return ''
        } else {
          return (
            '<form action="#" class="species_page_form">'+
              '<table><tr><td>Notes:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td>'+this.notes()+'</td></tr></table>'+
            '</form>'
          )
        }
      },

      notes: function () {
        var attrs = this.taxon().attributes()
        return this._textAreaOrText('notes', attrs.notes, { rows: 4, width: 665 })
      },
      
       _initializeSWFUpload: function() {

      }
    }
  })
});
