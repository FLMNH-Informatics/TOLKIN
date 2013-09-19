//= require <widget>
//= require <roles/tabbed>
//= require <swf_upload/init>
//= require <open_layers/init>
//= require "image_gallery"
//= require <widgets/taxa/collections_catalog>
//= require <widgets/taxa/new_window>
//= require <widgets/taxa/synonyms_catalog>



Module('Taxa', function () {
  JooseClass('TabbedBox', {
    isa: Widget,
    does: [ TOLJS.role.Tabbed],
    has: {
      context: { is: 'ro', required: true, nullable: false },
      taxon: { is: 'ro', required: true, nullable: false },
//      synonyms: { is: 'ro', required: true, nullable: false },
//      imageGallery: { is: 'ro', init: function () { return  }},
      frame: { is: 'ro', required: true, nullable: false },
      currentTab: { is: 'rw', init: 'nomenclature' },
      tabs: {is: 'ro', init: function () {return [ 'nomenclature', 'distribution', 'description', 'collections', 'molecular_data', 'images', 'literature', 'links' ]}},
      widgets: { is: 'ro', init: function () { return $Reg({
        collectionsCatalog:
          new Taxa.CollectionsCatalog({
            context: this.context(),
            parent:  this,
            taxon:   this.taxon(),
            frame: this.frame()
          }),
        taxonOutlinksTable:
          new Taxa.TaxonOutlinksTable({
            parent: this,
            context: this.context(),
            taxon: this.taxon()
        }),
        imageGallery:
          new Taxa.ImageGallery({
            parent: this,
            context: this.context(),
            taxon: this.taxon()
          }),
        synonymsCatalog:
          new Taxa.SynonymsCatalog({
            context: this.context(),
            parent: this,
            taxon: this.taxon(),
            frame: this.frame()
          })
      }, this)}}
    },
    override: {

      _transitionTabsAndContent: function (element, options) {
        options = options || {};
        if(element.up('.tab').id.match(/^(\w+)_tab$/)[1] == "distribution"){
        
          if($(this.id()).down('.geographic_map').innerHTML.blank()){
            this._map = new OpenLayers.Map('geomap');
            this._initMap(this._map);
          }
        }
        this.SUPER(element, { afterFinish: function () {
            if(this._map) { this._map.setCenter(new OpenLayers.LonLat(0,0), 1); }
            if(options.afterFinish) {
              options.afterFinish();
            }
        }.bind(this)});
        
      }
    },
    methods: {
      onClick: function (event) {
        Event.delegate({

          'input.delete_citation':function(event){
            var cit_id = event.element().up('*[data-citation-id]').readAttribute('data-citation-id');
            var tabb_box = this;
            var me = this;
            //var cit_delete_html = event.element().up('tr');
            event.stop();
            if(this.context().interactMode() == 'edit') {
              if (confirm('Are you sure you want to remove this citation?')) {
                me.notifier().working('Removing citation ...')
                var cit_input = {cit_id : cit_id}
                new Ajax.Request('/projects/'+params['project_id']+'/taxa/'+this.taxon().id()+'/delete_citation', {
                  method:'delete',
                  parameters: cit_input ,
                  onSuccess: function() {
                    var i=0;
                    var arr_cit = tabb_box.taxon().attributes().citations;
                    if(arr_cit) {
                      var index = arr_cit.citations.index(function (citation) {
                        return citation.citation.id == parseInt(cit_id)
                      })
                      arr_cit.citations.splice(index,1);
                      me.notifier().success('Citation removed.');
                      me.frame().render();
                      me.frame().refresh();
                    }
                  },
                  onFailure: function () {
                    me.notifier().error('Failed to remove citation');
                  }
                });
              }
            } else {
              alert('Cannot delete in Browse Mode');
            }
          //this.loadNewCitaionWindow(event.element().id);
          },
          'input.citation_edit':function(event){
            var citationId = event.element().up('*[data-citation-id]').readAttribute('data-citation-id');
            //var ids = event.element().readAttribute('data-id').match(/(\d+)_(\d+)/)
            this.frame().loadPage('project_library_citation_path', { id: citationId })

//            var me = this
//            new Ajax.Request("/projects/"+me.params().projectId+"/citations/"+citationId, {
//            method:"get",
//            onSuccess: function (transport) {
//              var window = me.frame();
//              //var window = new Taxa.NewWindow({parent: me.viewport(), taxon: me.taxon() });
//              //me.viewport().widgets().add(window);
//              window.render({yield: transport.responseText});
//              window.display();
//            }
//            });
          },
          '.citation_search':function(event){
            this._frame.loadPage('load_citation_search_widget_project_taxon_path', { id: this.params().id });
          //event.stop();
          //var window = new Taxa.NewWindow({parent: this.viewport(), taxon: this.taxon() });
          //this.viewport().widgets().add(window);
          //window.loadCitationSearch(this.params().id);
          }
        }).bind(this)(event);
      },
      show: function () { },
      render: function(){ },
      _beforeTransitionTabsAndContent: function(event) {},

      imageGallery: function () {
        return this.widgets().get('imageGallery')
      },

     //   postRender: function () {
     //       this.widgets().get('imageGallery').postRender();
     //   },

      _initMap: function(map) {
       
        map.addControl(new OpenLayers.Control.LayerSwitcher());
        var gphy = new OpenLayers.Layer.Google(
          "Google Physical",
          {
            type: G_PHYSICAL_MAP
          }
        );
        var gmap = new OpenLayers.Layer.Google(
          "Google Streets", // the default
          {
            numZoomLevels: 20
          }
        );
        var ghyb = new OpenLayers.Layer.Google(
          "Google Hybrid",
          {
            type: G_HYBRID_MAP,
            numZoomLevels: 20
          }
        );
        var gsat = new OpenLayers.Layer.Google(
          "Google Satellite",
          {
            type: G_SATELLITE_MAP,
            numZoomLevels: 20
          }
        );
        map.addLayers([gphy, gmap, ghyb, gsat]);
        var size = new OpenLayers.Size(13,13);
        var offset = new OpenLayers.Pixel(-(size.w/2), -(size.h/2));
        var icon = new OpenLayers.Icon((params['path_prefix']||'')+'/javascripts/img/tol-mkr-gold-sm.png', size, offset);
        
        var colGRSS = new OpenLayers.Layer.GeoRSS(
          'GeoRSS',
          Route.forPathname('project_taxon_collections_path').getInterpolatedPath(Object.extend(params, { taxon_id: this.taxon().id() }))+
            ".rss?"+Object.toQueryString({
              'select[]': [ 'id', 'collector', 'collection_number', 'country', 'island', 'state_province',
                'locality', 'start_date', 'calc_lat_dd', 'calc_long_dd' ],
              conditions: 'null[^calc_lat_dd]+null[^calc_long_dd]'
            }),
          {
            icon: icon
          });
        colGRSS.popupSize = new OpenLayers.Size(250,60);
        map.addLayer(colGRSS);
        map.setCenter(new OpenLayers.LonLat(0,0), 1);
      }

//      _initializeSWFUpload: function() {
//
//        var swfu;
//        //                 window.onload = function () {"
//        swfu = new SWFUpload({
//          // Create the custom swfupload_photos_path in the routes.rb file"
//          upload_url : '/images/swfupload',
//          file_size_limit : '3 MB',
//          file_types : '*.jpg',
//          file_types_description : 'JPG Images',
//          file_upload_limit : '0',
//
//          file_queue_error_handler : fileQueueError,
//          file_dialog_complete_handler : fileDialogComplete,
//          upload_progress_handler : uploadProgress,
//          upload_error_handler : uploadError,
//          upload_success_handler : this._uploadSuccess,
//          upload_complete_handler : uploadComplete,
//          upload_start_handler : uploadStart(this.taxon().id(),"Taxon"),
//
//          custom_settings : {
//            upload_target : 'divFileProgressContainer'
//          },
//
//          // Button Settings"
//          button_image_url : "/images/spyglass.png",
//          button_placeholder_id : "spanButtonPlaceholder",
//          button_width: 180,
//          button_height: 18,
//          button_text : '<span class="button">Select Images <span class="buttonSmall">(3 MB Max)</span></span>',
//          button_text_style : '.button { font-family: Helvetica, Arial, sans-serif; font-size: 12pt; } .buttonSmall { font-size: 10pt; }',
//          button_text_top_padding: 0,
//          button_text_left_padding: 18,
//          button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
//          button_cursor: SWFUpload.CURSOR.HAND,
//
//          // Flash Settings
//          flash_url : "/assets/swfupload.swf",
//          debug: false
//
//        });
//
//      }
    }
  })
});
