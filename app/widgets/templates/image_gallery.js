//= require <widget>
//= require <user_image>
//= require <swf_upload/init>
//= require <roles/polling>
//= require <tolkin/swf_upload>

JooseModule('Templates', function () {
  JooseClass('ImageGallery', {
    isa: Widget,
    does: Polling,
    has: {
      joinObj        : { is: 'ro', required: true, nullable: false },
      joinClassname  : { is: 'ro', required: true, nullable: false },
      removeImagePath: { required: true, nullable: false },
      galleryWidth   : { is: 'ro', required: true, nullable: false },
      galleryHeight  : { is: 'ro', required: true, nullable: false },
      images:      { is: 'ro', lazy: true, init: function () { return this._loadImages() }},
      currImage:   { is: 'rw', lazy: true, init: function () { return(
          this.images().first() && this.images().first().scaleTo(this.galleryWidth()*(2/3), this.galleryHeight())
      )}},
      thumbsScrollInterval: { }
    },
    after: {
      initialize: function () {
        this.handlers().push(
          this.frame().on('state:displayed', function () {
            this.postRender()
          }, this)
        )
        /*var me = this
        this.poll({
          on: function () {
            return (this.interactMode().get() &&
              (!this.iCollection || this.iCollection().is('loaded'))
            )
          },
          run: function () {
            me.interactMode().addObserver(this, function () {
              me.render()
              if($(me.id())) { me.refresh() }
            })
          }
        })*/
      }
    },
    methods: {
      removeImagePath: function() {
        alert('you must override me in super class');
      },

      initSwfUpload: function () {
        new TOLKIN.SwfUpload({
          parentId: this.id(),
          notifier: this.context().notifier(),
          options: {
            post_params: {
              'options[image_type]': this.joinClassname(),
              'options[id]': this.joinObj().id() },
            upload_success_handler: this.onUploadSuccess.bind(this) } }) },

      setCurrImage: function (image) {
        this._currImage = image && image.scaleTo(this.galleryWidth()*(2/3), this.galleryHeight())
      },

      onUploadSuccess: function (file, serverData) {
        var notifier = this.context().notifier();
          if(serverData.isJSON()) {
            // race condition could crop up here with image number being given not corresponding to order in which image is added
            var image = new TOLKIN.UserImage({ data: serverData.evalJSON().image, collection: this.images()});
            this.setCurrImage(image);
            $(this.id()).down('.igallery-thumbs-list').setStyle({ width: this._thumbsWidth() });
            $(this.id()).down('.igallery-thumbs').down('ul').insert({ bottom: this._imageThumbnail(image) });
            this.renderCurrImage();
            this.renderImageCounter();
          } else {
            notifier.error('Problem uploading file: '+serverData);
          }
      },

      _loadImages: function () {
        return this.joinObj().attributes().images.images.inject([], function (arr, image) {
          return(new TOLKIN.UserImage({ data: image.image, collection: arr}) && arr)
        }, this);
      },



      onMouseover: function (event) {
        var me = this;
        Event.delegate({
          '.igallery-back': function () {
            var direction = 'left';
            me._thumbsScrollInterval = setInterval(function () { me._scrollThumbs(direction) }, 10)
          },
          '.igallery-forward': function () {
            var direction = 'right';
            me._thumbsScrollInterval = setInterval(function () { me._scrollThumbs(direction) }, 10)
          }
//          '.igallery-image img': function () {
//            Effect.BlindUp($(me.id()).down('.igallery-image-description'), { queue: 'end', duration: '0.3' });
//          }
        })(event)
      },

      _scrollThumbs: function (direction, click) {
        var scrollDiv = $(this.id()).down('.igallery-thumbs').down('div');
        switch(direction) {
          case 'left':
            scrollDiv.scrollLeft = scrollDiv.scrollLeft - (click ? 60 : 1)
            break;
          case 'right':
            scrollDiv.scrollLeft = scrollDiv.scrollLeft + (click ? 60 : 1)
            break;
        }
      },

      onMouseout: function (event) {
        var me = this;
        Event.delegate({
          '.igallery-back': function () {
            clearInterval(me._thumbsScrollInterval)
          },
          '.igallery-forward': function () {
            clearInterval(me._thumbsScrollInterval)
          }
//          '.igallery-image img': function () {
//            Effect.BlindDown($(me.id()).down('.igallery-image-description'), { queue: 'end', duration: '0.3' });
//          }
        }).bind(this)(event)
      },

      _imageId: function (image) {
        return image.id()
      },

      onClick: function (event) {
        var me = this;
        Event.delegate({
          'li': function () {
            var imageId = event.element().readAttribute('data-image-id');
            if(typeof me.iCollection == 'function'){
                if(me.iCollection().state().is('unloaded')) { me.iCollection().load() }
                me.iCollection().on('state:loaded', function () {
                    me.setCurrImage(me.images().detect(
                        function (image) { return me._imageId(image) == imageId },
                        me
                    ) )
                    me.renderImageCounter();
                    me.renderCurrImage();
                }, { once: true }, me)
            }else{

                me.setCurrImage(me.images().detect(function (image) { return image.id() == imageId }));
                me.renderImageCounter();
                me.renderCurrImage();
            }
            
          },
          '.igallery-delete-image-control': function () {
            me._removeImage();
          },
          '.igallery-back': function () {
            var direction = 'left';
            me._scrollThumbs(direction, true)
          },
          '.igallery-forward': function () {
            var direction = 'right';
            me._scrollThumbs(direction, true)
          }
        }).call(this, event)

      },

      _removeImage: function () {
        var me = this;
        var confirmed = window.confirm('Are you sure you want to delete this image?')
        if(confirmed) {
          new Ajax.Request(this.removeImagePath(me.currImage().id()), {
            method: 'delete',
            onSuccess: function () { me._afterRemoveImage() },
            onFailure: function () { me.context().notifier().error('Problem encountered while deleting image.'); }
          });
        }
      },

      _afterRemoveImage: function () {
        var place = this.currImage().place();
        this.images().splice(place - 1, 1);
        $(this.id()).down('.igallery-thumbs-list').down('li:nth-child('+place+')').remove();
        $(this.id()).down('.igallery-thumbs-list').setStyle({ width: this._thumbsWidth()+'px' });
        this.setCurrImage(this.images()[place - 1] || this.images()[place - 2]);
        this.renderImageCounter();
        this.renderCurrImage();
      },

      renderCurrImage: function () {
        $(this.id()).down('.igallery-image-and-description-wrapper').replace(this.renderToStringCurrImage())
      },

      renderToStringCurrImage: function () {
        return(
          "<div class='igallery-image-and-description-wrapper'>"+
              (!this.currImage() ? '' :
          "<table border='1' style='border:1px'>"+
            "<tr><td>"+
                "<div class='igallery-image-wrapper' style='position: relative; width: "+this.galleryWidth()*(2/3)+"px; height: "+this.galleryHeight()+"px; top: 0px; right:0px'>"+

                "<div class='igallery-image' "+
                  "style='"+
                    "position: relative;"+
                    "width: "+this.currImage().width()+"px;"+
                    "height:"+this.currImage().height()+"px"+
                  "'"+
                ">"+
                  "<a href='"+this.currImage().imageSrc()+"' target='_blank'>"+
                    "<img style='width: "+this.currImage().width()+"px; height: "+this.currImage().height()+"px; ' src='"+this.currImage().imageSrc()+"' />"+
                  "</a>"+
                "</div>"+
                 ((this.context().interactMode() == 'edit') ? this._imageOptions() : '')+
               "</div>"+
          "</td><td "+
                "class='igallery-image-description' style='"+
                "width: "+this.galleryWidth()*(1/3)+"px;"+
                "height: "+this.galleryHeight()+"px;"+
                "background-color: white;"+
                "opacity: 0.8;"+
                "margin-bottom: 0px;"+
                "font-size: 11px"+
              "'>"+(!this.currImage() ? '' :
                this._imageDescription())+
              "</div>"+
        "</td></tr></table>"
        )+
        "</div>"
        )
      },

      onSubmit: function (event) {
        var me = this;
        me.context().notifier().working('Updating image info ...');
        event.stop();
        event.element().request({
          onSuccess: function (transport) {
            var updatedInfo = transport.responseJSON.image;
            me.currImage().update(updatedInfo);
            me.context().notifier().success('Image info successfully updated.')
          }
        });
      },

      _imageDescription: function () {
        return(""+
          ( "<div style='width: 100%; height: 100%; position: relative'>"+
              ((this.context().interactMode() == 'edit') ?
                "<div style='padding-bottom: 12px'>"+
                  "<form method='post' action='/projects/"+params['project_id']+"/images/"+this.currImage().id()+"'>"+
                    "<input type='hidden' name='_method' value='put' />"+
                    "<table style='width: 100%; height: 100%; padding: 6px'>"+
                      "<tr>"+
                        "<td>Caption:</td>"+
                      "</tr>"+
                      "<tr>"+
                        "<td><textarea name='image[caption]' rows='5' style='width: 100%'>"+(this.currImage().caption() || '')+"</textarea></td>"+
                      "</tr>"+
                      "<tr>"+
                        "<td>Photographer:</td>"+
                      "</tr>"+
                      "<tr>"+
                        "<td><input type='text' style='width: 100%' name='image[photographers_credits]' value='"+(this.currImage().photographer() || '')+"' /></td>"+
                      "</tr>"+
                    "</table>"+
                    "<input style='float: right; margin-right: 6px' type='submit' value='Save' />"+
                  "</form>"+
                "</div>"
                :
                (this.currImage().caption().blank() && this.currImage().photographer().blank() ? '' :
                  "<p style='padding: 6px 6px 12px 6px; margin: 0'>"+
                    this.currImage().caption()+
                    (this.currImage().photographer().blank() ? '' : "<br /><br />Photographer: "+this.currImage().photographer())+
                  "</p>"
                )
              )+
              (""+
                "<span style='position: absolute; bottom: 0'>Dimensions: "+
                this.currImage().origWidth()+
                " X "+
                this.currImage().origHeight()+
                "</span>"
              )+
            "</div>"
          )
        )
      },

      _imageOptions: function () {
        return(
          "<div class='igallery-delete-image-control' style='"+
            "padding: 6px;"+
            "background-color: white;"+
            "opacity: 0.8;"+
            "position: absolute;"+
            "top: 0px;"+
            "right: 0px;"+
            "color: #06C;"+
            "cursor: pointer;"+
            "font-size: 11px;"+
          "'>"+
            "<img src='/images/x.png' /> "+
            "Delete"+
          "</div>"+
           "<div class='igallery-text' style='"+
            "background-color: white;"+
            "position: absolute;"+
            "color: #06C;"+
            "cursor: pointer;"+
            "font-size: 11px;"+
            "bottom: 0px"+
          "'>"+
            "<a href='"+this.currImage().imageSrc()+"' target='_blank'>Click to Enlarge</a>"+
          "</div>"
        )
      },

      _currImageOffset: function () {
        return((this.galleryWidth() - this.currImage().width()) / 2)
      },

      renderToString: function () {
        return(
          "<div id='"+this.id()+"' class='widget image-gallery'>"+
            "<div class='igallery-nav'>"+
              "<table style='height: 2em; position: relative; width: "+(this.galleryWidth()+30)+"px;'>"+
                "<tr>"+
                  "<td class='igallery-back'><a href='#'>&lt;&lt;</a></td>"+
                  "<td class='igallery-thumbs' style='width: 100%'>"+
                      this._imageThumbnails()+
                  "</td>"+
                  "<td class='igallery-forward'><a href='#'>&gt;&gt;</a></td>"+
                "</tr>"+
              "</table>"+
            "</div>"+
            "<div class='igallery-controls' style='height: 2.5em'>"+
              this.renderToStringImageCounter()+
              "<div class='igallery-add-image-control' style='float: right'>"+
                "<span id='"+this.id()+"_add_image_control_placeholder'></span>"+
              "</div>"+
            "</div>"+

            this.renderToStringCurrImage()+

          "</div>"
        )
      },

      renderImageCounter: function () {
        $(this.id()).down('.igallery-image-counter').replace(this.renderToStringImageCounter())
      },

      renderToStringImageCounter: function () {
        return(
          "<div class='igallery-image-counter' style='float:left'>"+
            (this.currImage() ? this.currImage().place() : 0)+'/'+this.images().size()+
          "</div>"
        )
      },

      postRender: function () {
        this.poll({
          on: function () { return this.context().interactMode().get() },
          run: function () { if(this.context().interactMode() == 'edit') { this.initSwfUpload() } }
        })
      },

      _imageThumbnails: function () {
        var i = 0;
        return(
          "<div style='overflow: hidden; width: "+this.galleryWidth()+"px'>"+
            "<ul class='igallery-thumbs-list' style='width: "+this._thumbsWidth()+"'>"+
              this.images().inject('', function (out, image) {
                return out+this._imageThumbnail(image)
              }, this)+
            "</ul>"+
          "</div>"
        )
      },

      _thumbsWidth: function () {
        return(this.images().inject(0, function(sum, image) {
          // image width + right padding + border (both sides)
          return(sum+image.thumbWidth()+6+5)
        })+'px');
      },

      _imageThumbnail: function (image) {
        return(
          "<li style='float: left; padding-right: 5px'>"+
            "<img style='border: 3px solid #BBB; cursor: pointer' data-image-id='"+image.id()+"' src='"+image.thumbSrc()+"'/>"+
          "</li>"
        )
      }
    }
  })
});