Module('Library.Citations', function () {
  Role('FormsHelper', {
    requires: [ 
      'onSubmitSuccess',
      'onSubmitFailure',
      'onSubmitTimeout'
    ],
    has: {
      authors_deleted: { is: 'rw', init: $A([]) }
    },
    methods: {
      onClickMove: function (event) {
//        this.notifier().working()
        var authors = this.widget('authorsCatalog').authors()
        if(authors.is('unloaded')) { authors.load() }
        authors.on('state:loaded', function () {
          var dataArray = authors.entries()
          var dataId = event.element().up('tr').readAttribute('data-id');
          var catalog = this.widgets().get('authorsCatalog');
          for(var i in dataArray) {
            if(Object.values(dataArray[i]).first().id == dataId) {
              var curPos = parseInt(i)+1;
              break;
            }
          }
          var formElement = $(this.frame().id()).down('form.new_citation');
          if(event.element().hasClassName('moveTop')) {
            this._moveTop(curPos, dataArray, formElement, catalog);

          } else if(event.element().hasClassName('moveUp')) {
            this._moveUp(curPos, dataArray, formElement, catalog);

          } else if(event.element().hasClassName('moveDown')) {
            this._moveDown(curPos, dataArray, formElement, catalog);

          } else if(event.element().hasClassName('moveBottom')) {
            this._moveBottom(curPos, dataArray, formElement, catalog);
          }
//          this.notifier().success()
        }, { once: true }, this)

      },

      onClickRemove: function (event) {
        var e1, e2, e3
        var me = this;
        var catalog = this.widget('authorsCatalog')
        var collection = catalog.authors()
//        this.notifier().working()
        if(collection.is('unloaded')) { collection.load() }
        collection.on('state:loaded', function () {
          var selected = catalog.selected();
          if (selected.size() > 0) {
            if (collection.meta.className() == 'SyncCollection') {
              collection.entries().each(function (entry, index) { // insert and reposition entries in form
                  var id = Object.value(entry).id;
                  ( ( e1 = $(me.frame().id()).down('input[type="hidden"][name="citation[contributors][positions]['+id+']"]'))
                    && e1.writeAttribute('value', index+1)
                  ) || me._contribInsert(id, index+1);
                }, this);

                //TODO: xpath errors triggered on [contributors]: think its fixed now but check


              for(id in selected._ids._hash){
                (e1 = $('citation_contributors_ids_'+ id)) && e1.remove();
                (e2 = $('citation_contributors_positions_'+ id)) && e2.remove();
                (e3 = $('citation_contributors_names_'+ id)) && e3.remove();
                //if id is not a number then it is a new author
                if(!isNaN(Number(id))){
                  //this.authors_deleted().push(id);
                  $(catalog.id()).insert({before:
                    "<input type='hidden' name='citation[contributors][ids][]' value='!"+id+"' />"
                  });
                }
              }

              var colarr = [];
              collection.entries().each(function(key,val){
                if(selected._ids._hash[key.author.id]){
                  colarr.push(val)
                }
              })
              colarr.reverse();
              var len = colarr.length;
              for(var i=0; i<len; i++) {
                collection.entries().splice(colarr[i],1)
              }

            }
          }
          selected.deselectAll()
          catalog.refreshContents();
//          this.notifier().success()
        }, { once: false }, this)
      },


      onClick: function (event) {
        var me = this;
        Event.delegate({
          '.saveButton.active': function (event) {
            var form = event.element().up('.dialog').down('.new_citation');
            form.submit();
            me.poll({
              on: function () {return $('upload_frame').$('citation_status');},
              run: function () {
                if($('upload_frame').$('citation_status').innerHTML == 'success') {
                  me.onSubmitSuccess();
                } else {
                  me.onSubmitFailure();
                }
              },
              timeout: 30000,
              onTimeout: function () {
                me.onSubmitTimeout();
              }
            })
          },
          '.button.active': function (event) {
            switch(event.element().upper('.button').readAttribute('value')) {
              case 'Select'          :me.onClickSelect(event);break;
              case 'Remove'          :me.onClickRemove(event);break;
              case 'Create Publisher':me.onClickCreatePublisher(event);break;
              case 'Add Author'      :me.onClickAddAuthor(event);break;
              default:me.onClickMove(event);
            }
            
          }
        })(event);
      },

      onClickAddAuthor: function (event) {
        var authorsRcd = this.widget('authorsCatalog').authors()
        if (authorsRcd.is('unloaded')) {authorsRcd.load()}
        authorsRcd.on('state:loaded', function () {
          var me = this;
          var catArray = authorsRcd.entries()
          var hasItem = false;
          catArray.each(function(item){
            if(item.author.name == $F('citation_author_name_auto_input')){
              hasItem = true;
            }
          })
          if(!hasItem){
            this.notifier().working()
            new Ajax.Request(me.route('check_author_project_library_citation_path'),{
              method: 'get',
              parameters: {'name' : $F('citation_author_name_auto_input')},
              requestHeaders: {'Accept' : 'application/json'},
              onSuccess: function (transport) {
                me.notifier().success()
                var dataArray = authorsRcd.entries();

                dataArray.push(transport.responseJSON);
                var catalog = me.widgets().get('authorsCatalog');
                var name = Object.values(transport.responseJSON).first().name;
                var id = Object.values(transport.responseJSON).first().id;
                me._contribInsert(id, dataArray.size(),name);
                catalog.refreshContents();
              }
            });
          }// else {
//            this.notifier().success()
//          }
        }, { once: true }, this)
      },

      onClickCreatePublisher: function (event) {
        var me = this;
        me.notifier().working('Creating publisher ...');
        new Ajax.Request(me.route('project_library_publishers_path'), {
          parameters: {"publisher[name]": $F('publisher_name')},
          onSuccess: function () {
            me.notifier().success('Publisher created successfully.');
            new Ajax.Request(me.route('publishers_search_project_library_publishers_path'), {
              method: 'get',
              parameters: {
                object_type: 'citation',
                search: $F('publisher_name')
              },
              onSuccess: function (transport) {
                $('div_publisher').update(transport.responseText);
              },
              onFailure: function () {
                me.notifier().failure("Couldn't perform publisher search.");
              }
            });
          },
          onFailure: function () {
            me.notifier().failure('Problem creating publisher.');
          }
        });
      },

      onSubmit: function (event) {
        var me = this;
        Event.delegate({
          '.add_new_authors': function (event) {
            event.stop();
            event.element().request({
              requestHeaders: {
                Accept: 'application/json'
              },
              onSuccess: function (transport) {
                var dataArray = me.records().get('authors').data();
                dataArray.push(transport.responseJSON);
                var catalog = me.widgets().get('authorsCatalog');
                var id = Object.values(transport.responseJSON).first().id;
                me._contribInsert(id, dataArray.size());
                catalog.refreshContents();
              }
            });
          }
//           ,
//          '.new_citation': function (event) {
//            me.poll({
//              on: function () { return $('upload_frame').$('citation_status'); },
//              run: function () {
//                if($('upload_frame').$('citation_status').innerHTML == 'success') {
//                  me.onSubmitSuccess();
//                } else {
//                  me.onSubmitFailure();
//                }
//              },
//              timeout: 5000,
//              onTimeout: function () {
//                me.onSubmitTimeout();
//              }
//            })
//          }
        })(event);
      },

      _moveTop: function (curPos, dataArray, formElement, catalog) {
        this._moveEnd(-1, curPos, dataArray, formElement, catalog);
      },

      _moveUp: function (curPos, dataArray, formElement, catalog) {
        this._moveOne(-1, curPos, dataArray, formElement, catalog);
      },

      _moveDown: function (curPos, dataArray, formElement, catalog) {
        this._moveOne(+1, curPos, dataArray, formElement, catalog);
      },

      _moveBottom: function (curPos, dataArray, formElement, catalog) {
        this._moveEnd(+1, curPos, dataArray, formElement, catalog);
      },

      _moveOne: function (dir, curPos, dataArray, formElement, catalog) { // move direction +1 or -1
        var s1, s2, e1, e2;
        s1 = dataArray[curPos-1];
        s2 = dataArray[curPos-1+dir];
        dataArray[curPos-1+dir] = s1;
        dataArray[curPos-1] = s2;
        catalog.refreshContents();
        e1 = formElement.down('input[type="hidden"][name="citation[contributors][positions]['+Object.value(s1).id+']"]');
        e2 = formElement.down('input[type="hidden"][name="citation[contributors][positions]['+Object.value(s2).id+']"]');
        e1 ?
          e1.writeAttribute('value', curPos+dir)
        : this._contribInsert(Object.value(dataArray[curPos-1+dir]).id, curPos+dir, Object.value(dataArray[curPos-1+dir]).name);
        e2 ?
          e2.writeAttribute('value', curPos)
        : this._contribInsert(Object.value(dataArray[curPos-1]).id, curPos, Object.value(dataArray[curPos-1]).name);
      },

      _moveEnd: function (dir, curPos, dataArray, formElement, catalog) { // direction +1 or -1
        var dataEntry = dataArray.splice(curPos-1, 1)[0];
        var e1 = formElement.down('input[type="hidden"][name="citation[contributors][positions]['+Object.value(dataEntry).id+']"]');
        (dir > 0 ? dataArray.push : dataArray.unshift).call(dataArray, dataEntry);
        catalog.refreshContents();
        var range = (dir > 0) ? $A($R(curPos+1,dataArray.size())) : $A($R(1,curPos-1)).reverse(); // count forwards or backwards from point
        range.each(function(pos) {
          var id = Object.value(dataArray[pos-1-dir]).id
          var inputElement = formElement.down('input[type="hidden"][name="citation[contributors][positions]['+id+']"]');
          inputElement ?
            inputElement.writeAttribute('value', pos-dir)
          : this._contribInsert(id, pos-dir, Object.value(dataArray[curPos-1]).name);
        }, this);
        var newPos = (dir > 0) ? dataArray.size() : 1;
        e1 ?
          e1.writeAttribute('value', newPos)
        : this._contribInsert(Object.value(dataEntry).id, newPos, Object.value(dataArray[curPos-1]).name);
      },

      _contribInsert: function (id, position, name) {
        var e1;
        (e1 = $(this.frame().id()).down('input[type="hidden"][name="citation[contributors][ids][]"][value="!'+id+'"]'))
        && e1.remove();

        $(this.widget('authorsCatalog').id()).insert({before:
          "<input type='hidden' id='citation_contributors_ids_"+id+"' name='citation[contributors][ids][]' value='"+id+"' />"+
          "<input type='hidden' id='citation_contributors_positions_"+id+"' name='citation[contributors][positions]["+id+"]' value='"+position+"' />"+
          "<input type='hidden' id='citation_contributors_names_"+id+"' name='citation[contributors][names]["+id+"]' value='"+name+"' />"
        });
      }
    }
  });
});
