/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 7/27/11
 * Time: 5:33 PM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Created by JetBrains RubyMine.
 * User: nsantiago
 * Date: 7/25/11
 * Time: 4:10 PM
 * To change this template use File | Settings | File Templates.
 */
//= require <sync_record>
//= require <route>

  JooseClass('ImageAlbum', {
    isa: SyncRecord,
    classHas: {
      data:          { required: true, nullable: true },
      collection:    { is: 'ro', required: true, nullable: false },
      id:            { is: 'ro', init: function () { return this._data.id }},
      width:         { is: 'ro', lazy: true, init: function () { return this._data.width }},
      height:        { is: 'ro', lazy: true, init: function () { return this._data.height }},
      origWidth:     { is: 'ro', lazy: true, init: function () { return this._data.width }},
      origHeight:    { is: 'ro', lazy: true, init: function () { return this._data.height }},
      thumbSrc:      { is: 'ro', lazy: true, init: function () { return this._initThumbSrc() }},
      imageSrc:      { is: 'ro', lazy: true, init: function () { return this._initImgSrc() }},
      thumbWidth:    { is: 'ro', lazy: true, init: function () { return this._data.width } },
      thumbHeight:   { is: 'ro', lazy: true, init: function () { return this._data.height } },
      thumbFilename: { is: 'ro', lazy: true, init: function () { return this._data.file_name } },
      route:         { is: 'ro', init: function() { return Route.forPathname('project_image_path')}},
      memberRoute:   { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_image_path') }},
      collectionRoute: { is: 'ro', lazy: true, init: function () { return Route.forPathname('project_images_path') }}
    },
    methods: {
      caption:      function () { return this._data.caption || '' },
      photographer: function () { return this._data.photographers_credits || '' },

      update: function (data) { Object.extend(this._data, data) },

      place: function () {
        return(this.collection().collect(function(n) {return n.chr_image.id}).indexOf(this.id())+1)
      },

      // only accommodates scaling down for now
      scaleTo: function (scaleWidth, scaleHeight) {
        var scaleRatio;
        if(this.width() <= scaleWidth && this.height() <= scaleHeight) {

          // do nothing
        } else if( (this.width() / scaleWidth) <= (this.height() / scaleHeight) ) {

          scaleRatio = (this.height() / scaleHeight);
//          this._height = scaleHeight;
          this._height = Math.round(this._height / scaleRatio);
          this._width = Math.round(this._width / scaleRatio);
        } else {

          scaleRatio = (this.width() / scaleWidth);
          this._height = Math.round(this._height / scaleRatio);
//          this._width = scaleWidth;
          this._width = Math.round(this._width / scaleRatio);
        }
        return this;
      },

      _initImgSrc: function () {
        return(this._directory()+'/'+this._data.file_name+'?'+this._data.image_updated_at.gsub(/[A-Za-z:\-\s"]/, ''));
      },

      _initThumbSrc: function () {
        return(this._thumbDirectory()+'/'+this._data.file_name+'?'+this._data.image_updated_at.gsub(/[A-Za-z:\-\s"]/, ''));
      },

      _directory: function () {
        return('/system/images/'+this._data.id+'/original')
      },

      _thumbDirectory: function () {
        return('/system/images/'+this._data.id+'/thumb')
      },

      _idWithZeroes: function () {
        return(this._zeroes()+this._data.id)
      },

      _zeroes: function () {
        return '00000000'.substr(this._data.id.toString().length)
      },
      id: function() {
      return this._data.id}
    }
  })
