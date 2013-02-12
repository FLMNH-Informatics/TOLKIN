//= require <widget>

Module('Collections', function () {
  JooseClass('AnnotationsCatalogActionPanel', {
    isa: Widget,
    has: {
      catalog: { is: 'ro', init: function () { return this.parent() } },
      annotations: { is: 'ro', init: function () { return this.parent().annotations() } }
    },
    methods: {
      render: function () {
        if(this.parent().interactMode().toString() == 'edit') {
          return this.template('collections/_annotations_catalog_action_panel').evaluate({
            id: this.id(),
            count_num: this.parent().selected().size() > 0 ? ''+this.parent().selected().size()+' selected' : '',
            taxon_input_id: this.params().id + '_annotations_taxon_input',
            deter_input_id: this.params().id + '_annotations_determiner_input',
            date_input_id:  this.params().id + '_annotations_date_input',
            inst_input_id:  this.params().id + '_annotations_institution_input'
          })
        } else {
          return ''
        }//if edit mode
      },
      onClick: function (event) {
        Event.delegate({
          '.button.active': function (event) {
            switch(event.element().upper('.button').readAttribute('value')) {
              case 'Remove':
                this.onClickRemove(event)
                break;
              case 'Add':
                this.onClickAdd(event)
                break;
            }
          }
        }).call(this, event)
      },
      onClickAdd: function (event) {
        if ( this.annotations().is('unloaded') ) { this.annotations().load() }
        this.annotations().on('state:loaded', function () {
//          var tax, deter, date, inst
          var id = this.params().id
          var element = $(this.id())
          var fields = {
            taxon: element.down('input[name="annotations_inputs[taxon]"]'),
            determiner: element.down('input[name="annotations_inputs[determiner]"]'),
            date: element.down('input[name="annotations_inputs[date]"]'),
            institution: element.down('input[name="annotations_inputs[institution]"]')
          }
          var values = {
            taxon: fields.taxon.getValue(),
            determiner: fields.determiner.getValue(),
            date: fields.date.getValue(),
            institution: fields.institution.getValue()
          }
          Object.values(fields).each(function (f) { f.setValue('') })

//          tax = $(this.id()).down('input[name="annotations_inputs[taxon]"]').getValue() //$F(this.params().id + '_annotations_taxon_input')
//          $(this.params().id + '_annotations_taxon_input').setValue('')
//          deter = $F(this.params().id  + '_annotations_determiner_input')
//          $(this.params().id  + '_annotations_determiner_input').setValue('')
//          date  = $F(this.params().id  + '_annotations_date_input')
//          $(this.params().id+'_annotations_date_input').setValue('')
//          inst  = $F(this.params().id+'_annotations_institution_input')
//          $(this.params().id+'_annotations_institution_input').setValue('')

          var dataArray = this.catalog().annotations().entries()
          var dat = new Date();
          var newId = 'new_'+ dat.getTime();
          dataArray.push({
            annotation: {
              taxon: values.taxon,
              name: values.determiner,
              date: values.date,
              inst: values.institution,
              collection_id: id,
              id: newId
            }
          })
          this.catalog()._anObj.add.set(newId, {
            taxon: values.taxon,
            name: values.determiner,
            date: values.date,
            institution: values.institution
          })
          this.catalog().annotations().data().count = dataArray.size()
          this.catalog().selected().deselectAll()
          this.catalog().refreshContents();
        }, { once: true }, this)
        
      },
      onClickRemove: function (event) {
        if ( this.annotations().is('unloaded') ) { this.annotations().load() }
        this.annotations().on('state:loaded', function () {
          var catalog = this.catalog()
          var selected = catalog.selected();
          //if removing new annotation delete it from the add hash
          //if removing existing annotation add its id to the delete array
          $H(selected._ids._hash).each(function(key,val){
            if(this.catalog()._anObj.remove_ids.indexOf(key[0]) == -1){
              if (this.catalog()._anObj.add.get(key[0]) != undefined){
                this.catalog()._anObj.add.unset(key[0])
              } else {
                this.catalog()._anObj.remove_ids.push(key[0])
              }
            }
          }, this)

          var collection = this.catalog().annotations()

          if(selected.size() > 0) {
            if (collection.meta.className() == 'SyncCollection' || collection.meta.className() == 'SyncProxy') {
              var colarr = [];
              collection._data.annotations.each(function(key,val){
                if(selected._ids._hash[key.annotation.id]){
                  colarr.push(val)
                }
              })
              colarr.reverse();
              var len = colarr.length;
              for(var i=0; i<len; i++) {
                collection._data.annotations.splice(colarr[i],1)
              }
            }
          }

          selected.deselectAll()
          this.catalog().annotations()._data.count = this.catalog().annotations().entries().size()
          catalog.refreshContents();
        }, { once: true }, this)
      }
    }
  });
});