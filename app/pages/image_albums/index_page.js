//= require <page>
//= require <image_albums/image_list>

JooseModule('ImageAlbums', function () {
  JooseClass('IndexPage', {
    isa: Page,
    has: {
        canRender: { is: 'ro', init: false },
        widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
          imageList: new ImageAlbums.ImageList({ parent: this.frame() })
        }, this) } },
      templates: { is: 'ro', lazy: true, init: function () { return $Templates([
        'layouts/window'
      ], this) }}
    },
    methods: {
      onResponseSuccess: function(response){
        var me = this
        $('album_index').innerHTML = response.responseText;
        if ($('digg_pagination')) $('digg_pagination').remove()
        me.notifier().success('Received results.')
      },
      _newSearchRow: function (type){
        var row = '<tr>' +
            '<td>' +
              '<input class="button active cancel_search_term" type="button" data-searchtype="'+type+'" value="x"/>' +
            '</td>' +
            '<td>' + type.capitalize() + '</td>' +
            '<td>' +
              '<input type="text" name="search['+type+']"/>' +
            '</td>' +
          '</tr>';
        return row;
      },

      imageClick: function (event) {
        var imageId = event.element().up('.image').readAttribute('data-id');
        params['id'] = imageId;
        var window = this.context().viewport().widgets().get('window');
        window.on('page:loaded', function (event) {
          event.from().show();
        });
        window.loadPage('project_image_path', { id: imageId });
      },

      onSubmit: function(event){
        var me = this
          , form = event.element();
        me.notifier().working('Searching images...')
        event.stop()
        form.request({
          onSuccess: function(response){
            me.onResponseSuccess(response);
          },
          onFailure: function(response){
            me.notifier().error("Sorry, something went wrong.")
          }
        })
      },

      onChange: function (event){
        Event.delegate({
          'select': function(event) {
            var el = event.element()
              , type = event.element().value;
            $('search_terms').down('tbody').insert({bottom: this._newSearchRow(type)});
            el.options[el.selectedIndex].writeAttribute({"disabled":"disabled"});
            el.selectedIndex = 0;
            $('search_images').show();
          }
        }).bind(this)(event);
      },

      onClick: function(event) {
        var me = this;
        Event.delegate({
          '.image a img': function(event) {
            event.stop()
              if(me.context().currentSelection()) {
                  me.imageClick(event);
              } else { }
          },

          '.cancel_search_term': function (event){
            var type = event.element().dataset.searchtype
              , tbody= event.element().up('tbody');
            event.element().up('tr').remove();
            $$('option[value="'+type+'"]').first().removeAttribute('disabled');
            if (tbody.empty()){
              $('search_images').hide();
            }
          },

          '.pagination': function(event){
            if (event.element().localName == 'a'){
              event.stop();
              me.notifier().working('Loading images...')
              new Ajax.Request(event.element().href,{
                method: 'get',
                onSuccess: function(response){
                  me.onResponseSuccess(response);
                },
                onFailure: function(response){
                  me.notifier().error('Sorry, something went wrong.');
                }
              })
            }
          }
        }).bind(this)(event);
      }
    }
  })
});