JooseModule('TOLKIN', function () {
  JooseClass('UserImage', {
    has: {
      data:          {
        required: true,
        nullable: true
      },
      collection:    {
        is: 'ro',
        required: true,
        nullable: false
      },
      id:            {
        is: 'ro',
        lazy: true, 
        init: function () {
          if(!this._data) {
          }
          return this._data.id
        }
      },
      width:         {
        is: 'ro',
        lazy: true,
        init: function () {
          if(!this._data) {
          }
          return this._data.width
        }
      },
      height:        {
        is: 'ro',
        lazy: true,
        init: function () {
          if(!this._data) {
          }
          return this._data.height
        }
      },
      origWidth:     {
        is: 'ro',
        lazy: true,
        init: function () {
          if(!this._data) {
          }
          return this._data.width
        }
      },
      origHeight:    {
        is: 'ro',
        lazy: true,
        init: function () {
          if(!this._data) {
          }
          return this._data.height
        }
      },
      thumbSrc:      {
        is: 'ro',
        lazy: true,
        init: function () {
          return this._initThumbSrc()
        }
      },
      imageSrc:      {
        is: 'ro',
        lazy: true,
        init: function () {
          return this._initImgSrc()
        }
      },
      thumbWidth:    {
        is: 'ro',
        lazy: true,
        init: function () {
          if(!this._data) {
          }
          return this._data.width
        }
      },
      thumbHeight:   {
        is: 'ro',
        lazy: true,
        init: function () {
          if(!this._data) {
          }
          return this._data.height
        }
      },
      thumbFilename: {
        is: 'ro',
        lazy: true,
        init: function () {
          if(!this._data) {
          }
          return this._data.attachment_file_name
        }
      }
    },
    after: {
      initialize: function () {
        this.collection().push(this)
      }
    },
    methods: {
      caption:      function () {
        if(!this._data) {
        }
        return this._data.caption || ''
      },
      photographer: function () {
        if(!this._data) {
        }
        return this._data.photographers_credits || ''
      },

      update: function (data) {
        Object.extend(this._data, data)
      },

      place: function () {
        return(this.collection().indexOf(this)+1)
      },

      // only accommodates scaling down for now
      scaleTo: function (scaleWidth, scaleHeight) {
        var scaleRatio;
        if(this.width() <= scaleWidth && this.height() <= scaleHeight) {
        // do nothing
        } else if( (this.width() / scaleWidth) <= (this.height() / scaleHeight) ) {
          scaleRatio = (this.height() / scaleHeight)
          this._height = scaleHeight
          this._width = Math.round(this._width / scaleRatio)
        } else {
          scaleRatio = (this.width() / scaleWidth)
          this._height = Math.round(this._height / scaleRatio)
          this._width = scaleWidth;
        }
        return this;
      },

      _initImgSrc: function () {
        //        return(this._directory()+this._data.filename+'?'+this._data.updated_at.gsub(/[A-Za-z:\-\s"]/, ''));
        if(!this._data) {
        }
        return(this._directory()+'/original/'+this.thumbFilename()+'?'+this._data.attachment_updated_at.gsub(/[A-Za-z:\-\s"]/, ''));
      },

      _initThumbSrc: function () {
        if(!this._data) {
        }
        //        return(this._directory()+this.thumbFilename()+'?'+this._data.thumb.updated_at.gsub(/[A-Za-z:\-\s"]/, ''));
        return(this._directory()+'/thumb/'+this.thumbFilename()+'?'+this._data.attachment_updated_at.gsub(/[A-Za-z:\-\s"]/, ''));
      },

      _directory: function () {
        //        return('/images/'+this._idWithZeroes().substr(0,4)+'/'+this._idWithZeroes().substr(4,4)+'/')
        //        return '/system/attachments/'+this._id
        //          i = 0;
        //          var path = "";
        //          while(i < 9){
        //           path = path + "/"+(((1000000000+this._id)+"").substr(1+i,3))
        //           i = i+3
        //         }

        var path =  [];
        (((1000000000+this._id)+"").substr(1,9)).scan(/\d{3}/ , function(num){
          return path.push(num[0])
        })
        return('/images/'+ path.join('/'))
      },

      _idWithZeroes: function () {
        if(!this._data) {
        }
        return(this._zeroes()+this._data.id)
      },

      _zeroes: function () {
        if(!this._data) {
        }
        return '00000000'.substr(this._data.id.toString().length - 1)
      }
    }
  })
});
