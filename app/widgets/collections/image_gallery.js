//= require <templates/image_gallery>

JooseModule('Collections', function () {
  JooseClass('ImageGallery', {
    isa: Templates.ImageGallery,
    has: {
      collection     : { is: 'ro', required: true, nullable: false },
      joinObj        : { is: 'ro', init: function () { return this.collection() }},
      joinClassname  : { is: 'ro', init: 'Collection' },
      removeImagePath: { is: 'ro', init: 'project_collection_image_path' },
      galleryWidth   : { is: 'ro', init: 450 },
      galleryHeight  : { is: 'ro', init: 200 }
    },
    methods: {
      removeImagePath: function (id) {
        return this.route(this._removeImagePath, { collection_id: this.params().id, id: id });
      }
    }
  })
});