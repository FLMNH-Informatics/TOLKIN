//= require <page>
//= require <image_albums/image_list>

JooseModule('ImageAlbums', function () {
    JooseClass('IndexPage', {
        isa: Page,
        has: {
            canRender: { is: 'ro', init: false },
            widgets: { is: 'ro', lazy: true, init: function () { return $Widgets({
              imageList: new ImageAlbums.ImageList({ parent: this.frame() })
            }, this) } }
        },
        methods: {
            _imageClick: function (event) {
                    var imageId = event.element().up('.image').readAttribute('data-id');
                    params['id'] = imageId;
                    var window = this.context().viewport().widgets().get('window');
                    window.on('page:loaded', function (event) {
                        event.from().show();
                    });
                    window.loadPage('project_image_path', { id: imageId });
            },
            onSubmit: function(event){
                event.stop()
            },

            onClick: function(event) {
                var me = this;
                Event.delegate({
                    '.image a img': function(event) {
                      event.stop()
                        if(me.context().currentSelection()) {
                            me._imageClick(event);
                        } else {

                        }
                    },
                    '.image_gallery_search_button': function(event)
                    {
                        event.stop();
                      var search_parameters_count = $('MainDiv').childElementCount
                      var search_parameters = []
                      var search_terms = []
                      var original_element = $('MainDiv').childElements().first()
                      search_parameters.push(original_element.search.value)
                      search_terms.push(original_element.term.value)
                      var previous_element = original_element;
                      $('HiddenForm').innerHTML = '';
                      var sp = $('searchSelect').getValue();
                      var st = $('searchText').getValue();
                      if(!st.blank()){
                        $('HiddenForm').insert({
                            top: new Element('input', {type: 'hidden', name: 'search[]' + sp + '[]', value: st })
                        })
                      }
                      for(x = 0 ; x < search_parameters_count - 1 ; x++){
                        var current_element = previous_element.next()
                        sp = current_element.down().next().value;
                        st = current_element.down().next().next().value;
                        if(!st.blank()){
                          $('HiddenForm').insert({
                              top: new Element('input', {type: 'hidden', name: 'search[]' + sp + '[]', value: st })
                          })
                        }
                        previous_element = current_element;
                      }
                        this.startSearch($('HiddenForm').serialize(true));
                    },
                  '.pagination': function(event){
                    if (event.element().localName == 'a'){
                      event.stop();
                      this.startSearch(event.element().search.toQueryParams());
                    }
                  }
                }).bind(this)(event);
            },
            startSearch: function(options){
              options = options || {}
              var me = this;
              this.notifier().working('Searching...')
              new Ajax.Request(
                me.route('search_project_image_albums_path'), {
                  method: 'get',
                  requestHeaders: { Accept: 'text/html' },
                  parameters: options,
                  onSuccess: function (transport) {
                    $('album_index').innerHTML = transport.responseText;
                    me.notifier().success('Received results.')
                  }
                }
              )
            }
        }
    })
});