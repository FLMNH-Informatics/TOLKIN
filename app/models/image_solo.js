//= require <sync_record>
//= require <sync_records/attribute>

JooseClass('ImageSolo', {
//  isa: SyncRecord,
//  classHas: {
//
//    primaryKey: { is: 'ro', init: function () { return new SyncRecords.Attribute({ name: 'image_id' }) } }
//  },
    has: {attribute: {is: 'ro', init: null},
    id:         {is: 'ro', init: null},
    context: { is: 'ro', required: true, nullable: false }
    },
    before: {
            initialize: function () {
                this.loadAttributes()
                //alert('hello')
                //this._id = this.params().id
            }
        },
    after: {
            initialize: function () {
                //alert('hello')
                //this._id = this.params().id
            }
        },
  methods: {
      _textAreaOrText: function(fieldName, value, options) {
    options || (options = {});
    var rows = options.rows || 4;
//    var cols = options.cols || 40;
    var width = options.width || 450;
    if(!value || value == 'null') {
      value = ''
      }
    var output="";//="<table id='taxon_description'><tr id='row1'>"

    switch(this.frame().interactMode().toString()) {
      case 'browse':
        //  if(!value || value.strip() == '') {
        //       value = "<span class='empty'>None</span>";
        //   }
        //   return value;
        if(value=="")
          // output+="<td class='value' colspan='3' align='center'><span class='empty'>No Description</span></td>"
          output +=  "<span class='empty'>None</span>";
        if(value!="")
        {
          //output+="<td align='center' class='value' colspan='3'>"+value+"</td>"
          //output+="</tr></table>
          output =  "<div class='value' style='width:"+width+"px'>" + value + "</div>";
        }
        return output;
      case 'edit'  :
        // output+="<td align='center' class='value' colspan='3'><textarea id='taxon_#{fieldName}_textarea' name='taxon[#{fieldName}]'>#{value}</textarea>".interpolate({
        //   fieldName: fieldName,
        //  value: value
        output="<textarea id='taxon_#{fieldName}_textarea' rows='"+rows+"' style='width:"+width+"px' name='taxon[#{fieldName}]'>#{value}</textarea>".interpolate({
          fieldName: fieldName,
          value: value.replace(/<br\/>/g,"\n")
        });
        //output+="</tr></table>"
        return output;
    }
  },

  _textFieldOrText: function(fieldName, value, size, options) {
    if(!value || value == 'null') {
      value = ''
      }
    options = options || { }
    value = String(value);
    var width = options.width || 450;
    var styleOption;
    switch(this.frame().interactMode().toString())  {
      case 'browse':
        if(!value || value.strip() == '')
        {
          value = "<span class='empty'>None</span>";
        }
        else
        {
          if(options['link_id'])
          {
            value = "<span class='link' data-taxon-id='"+options['link_id']+"'>" + value + "</span>";
          }
          value = "<div class='value' style='width:"+width+"px'>"+value+"</div>"
        }
        return value;
      case 'edit':
        if(!value || value.strip() == '' || value == "null")
        {
          value = "";
        }
        return "<input type='text' size='#{size}' name='taxon[#{fieldName}]' value='#{value}' />".interpolate({
          size: size,
          fieldName: fieldName,
          value: value,
          styleOption: styleOption
        });
    }
  },

      renderToString: function() {

                var attrs = this.image().attributes()
                var object = {
                    image                                             : attrs,
                    "caption"                                         : this._textFieldOrText('caption', attrs.caption, 58),
                    "photographers_credits"                            : this._textFieldOrText('photographers_credits', attrs.photographers_credits,65)

                };
                object["is_selected('"+this.tabbedBox().currentTab()+"')"] = 'selected';
                var content = this.frame().templates().get('image/show').evaluate(object);
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
      loadAttributes: function(options) {
      var image = this;
      new Ajax.Request(Route.forPathname('project_image_path').getInterpolatedPath(params), {
        requestHeaders: {
          Accept: 'application/json'
        },
        method: 'get',
        parameters: {
          'select[]': ['caption', 'photographers_credits']
        },
        onSuccess: function(transport) {
          image.attributes = transport.responseJSON.image
            if(options.callback) {
            options.callback();
          }
        },
        onFailure: function() {
          Notifier.error('Could not retrieve image.');
        }
      })
    },
//      loadCollections: function(options) {
//        this._loadHasManyRelation('collections', Object.extend(options, {
//          only: 'id,collector,collection_number',
//          callback: function() {
//            this.collections.each(function(collection) {
//              collection.label = collection.collector + " " + collection.collection_number;
//            });
//          }.bind(this)
//        }));
//      },
//
//      loadSynonyms: function(options) {
//        this._loadHasManyRelation('synonyms', Object.extend(options, {
//          only: 'id,name'
//        }));
//      },

    requestPath: function() {
      return "/projects/" + params['project_id'] + "/image_albums/" + this.id();
    }
  },
//  override: {
//    _processLoad: function(object) {
//      //object.namestatus = object.namestatus || { };
//      if (object.namestatus && object.namestatus.status) {
//        object.namestatus.status = object.namestatus.status.gsub(/_/, ' ')
//      }
//      object.created_at = Date.format(object.created_at);
//      object.updated_at = Date.format(object.updated_at);
//      //object.collections_count = object.collections.size();
//      //object.collections = object.collections.slice(0, 20);
//      return this.SUPER(object);
//    }
//  },
  classMethods: {
//    destroy: function (item_type, context, tree_view_obj) {
//      context.notifier().working('Deleting current selection ...');
//      new Ajax.Request("/projects/" + params['project_id'] + "/taxa/destroy_multiple", {
//        method: 'post',
//        parameters:item_type ,
//        onSuccess: function(transport) {
//          deleted_taxon = transport.responseText.evalJSON();
//          for(i=0; i<deleted_taxon['deleted'].length ; i++){
//            if($('taxon_' + deleted_taxon['deleted'][i] + '_node')){
//              $('taxon_' + deleted_taxon['deleted'][i] + '_node').remove();
//        //      context.globalCart().remove(item_type.type.capitalize(),deleted_taxon['deleted'][i]);
//              tree_view_obj.selected().deselectId(deleted_taxon['deleted'][i]);
//            }
//          }
//          taxon_root_node_add = '<tr id="taxon_#{id}_node" class="tree_view_node"><td class="tree_view_expander">#{expander}</td><td><input type="checkbox" value="#{id}"/></td><td><div class="tree_view_node_name"><span >#{name}</span></div><table class="tree_view_node_children"></table></td></tr>'
//          deleted_taxon['root_elements'].each(function(node){
//            Element.insert($('viewport_content_frame_taxa_tree_view').down('.tree_view_node'), {before: taxon_root_node_add.interpolate({name: node['name'],id: node['id'],expander: node['has_children'] ?  '+' : ''})})
//          });
//          //context.globalCart().removeForType(item_type.type);
//
////          context.currentSelection().remove();
//          context.notifier().success('Current Selection destroyed');
//        },
//        onFailure: function(){
//          context.notifier().error('problem deleting current selection');
//        }
//    });
//  }
}
});


