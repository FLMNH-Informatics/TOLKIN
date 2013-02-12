//= require <page>
//= require <collection>
//= require <annotation>
//= require <collections/annotations_catalog>
////= require <livevalidation>

JooseModule('Collections', function () {
  JooseClass('NewPage', {
    isa: Page,
    has: {
      canRender: { is: 'ro', init: true },
      title: { is: 'ro', init: 'Collection : New' },
      savable: { is: 'ro', init: true },
      widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
        taxonComboBox: new Collections.TaxonComboBox({
          parent: this.frame(),
          object: new Collection({ context: this.context() })
        }),
        annotationsCatalog: new Collections.AnnotationsCatalog({
          parent: this.frame(),
          annotations: Annotation.collection({ context: this.context(), data: { count: 0, annotations: [] } })
        })
      }, this) } },
      htmlLoader: { is: 'ro', init: function () {
        return $HtmlLoader({
          pathname: 'new_project_collection_path'
        }, this)
      } }
    },
    methods: {
      onChange: function(event){
        Event.delegate({
          '#lat_long_select': function(event){
            $('lat_dms_table').toggle();
            $('long_dms_table').toggle();
            $('lat_dd_table').toggle();
            $('long_dd_table').toggle();
          }
        })(event);
      },

      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            me.notifier().working('Creating collection ...');
            me.widget('annotationsCatalog')._anObj.add.each(function (key,val){
              //before submiting form add any annotations changes to form
              //para[key[0]] = { date: key[1].date, institution: key[1].institution, name: key[1].name, taxon: key[1].taxon }
              $(me.frame().id()).down('form').insert({
                bottom: "<input type='hidden' name='annotations_add["+key[0]+"][date]' value='"+ key[1].date +"' />"
                  + "<input type='hidden' name='annotations_add["+key[0]+"][institution]' value='"+ key[1].institution +"' />"
                  + "<input type='hidden' name='annotations_add["+key[0]+"][name]' value='"+ key[1].name +"' />"
                  + "<input type='hidden' name='annotations_add["+key[0]+"][taxon]' value='"+ key[1].taxon +"' />"
              })
            })
            me.widget('annotationsCatalog')._anObj.add = $H({})//reset the hash

            $(me.frame().id()).down('form').request({
              requestHeaders: { Accept: 'application/json' },
              onSuccess: function (transport) {
                me.notifier().success('Collection successfully created.');
                (new Collection({ context: me.context() })).fire('create');
                me.frame().loadPage('project_collection_path', { id: transport.responseJSON.id })
              }
            })
          }//,
          //          '.button.active': function (event) {
          //
          //            switch(event.element().upper('.button').readAttribute('value')) {
          //              case 'Remove'          : me.onClickRemove(event);          break;
          //              case 'Add'             : me.onClickAdd(event);             break;
          //
          //            }
          //
          //          }
        }).call(this, event)
      }//,

      //       onClickRemove: function (event) {
//
      //        var catalog = this.widget('annotationsCatalog');
      //        var selected = catalog.selected();
      //        var me = this
      //        //if removing new annotation delete it from the add hash
      //
      //        $H(selected._ids._hash).each(function(key,val){
      //
      //           if(me._anObj.add.get(key[0]) != undefined){
      //             me._anObj.add.unset(key[0])
      //           }
      //
      //        })
      //
      //        var collection = this.records('annotations')._records._object.annotations
      //
      //        if(selected.size() > 0) {
      //          if (collection.meta.className() == 'SyncCollection' || collection.meta.className() == 'SyncProxy') {
      //            var colarr = [];
      //            collection._data.annotations.each(function(key,val){
      //              if(selected._ids._hash[key.annotation.id]){
      //                colarr.push(val)
      //              }
      //            })
      //            colarr.reverse();
      //            var len = colarr.length;
      //            for(var i=0; i<len; i++) {
      //              collection._data.annotations.splice(colarr[i],1)
      //            }
      //          }
      //        }
      //
      //        selected.deselectAll()
      //        this.records().get('annotations')._data.count = this.records().get('annotations').entries().size()
      //        catalog.refreshContents();
      //
      //      },
      //
      //      onClickAdd: function (event) {
      //
      //        var catalog = this.widget('annotationsCatalog');
      //        var selected = catalog.selected();
      //
      //        var tax, deter, date, inst
      //        var id = this.params().id
      //        tax = $F('new_annotations_taxon_input')
      //        $('new_annotations_taxon_input').setValue('')
      //        deter = $F('new_annotations_determiner_input')
      //        $('new_annotations_determiner_input').setValue('')
      //        date  = $F('new_annotations_date_input')
      //        $('new_annotations_date_input').setValue('')
      //        inst  = $F('new_annotations_institution_input')
      //        $('new_annotations_institution_input').setValue('')
      //
      //        var dataArray = this.records().get('annotations').entries()
      //        var dat = new Date();
      //        var newId = 'new_'+ dat.getTime();
      //        dataArray.push({annotation: {collection_id: id, date: date, id: newId, inst: inst, name: deter, taxon: tax}})
      //        this._anObj.add.set(newId, { taxon: tax, name: deter, date: date, institution: inst})
      //        //var collection = this.records('annotations')._records._object.annotations
      //        this.records().get('annotations')._data.count = dataArray.size()
      //
      //        selected.deselectAll()
      //        catalog.refreshContents();
      //
      //      }

      //      onLoad: function () {
      //        var me=this;
      //        new Ajax.Request('/projects/' + params['project_id'] + '/collections/new', {
      //          requestHeaders: { Accept: 'text/javascript' },
      //          method: 'get',
      //          onSuccess: function(transport) {
      //            me._contents = transport.responseText;
      //            //me.frame().render();
      //            //me.frame().refresh();
      //            me.state().set('loaded');
      //            //if(options.onSuccess) { options.onSuccess() }
      //          }
      //        });
      //      },
      ////       loadContents: function (options) {
      ////
      ////       },
      //       renderToString : function () {
      //          return this._contents;
      //       }
      //    }

//      forms: { is: 'ro', init: function() { return new FormSet({
//           newForm: new Form({})
      //      }, this ) }
    }
  })
});
