//= require <templates/image_gallery>

JooseModule('Taxa', function () {
  JooseClass('ImageGallery', {
    isa: Templates.ImageGallery,
    has: {
      taxon          : { is: 'ro', required: true, nullable: false },
      joinClassname  : { is: 'ro', init: 'Taxon' },
      joinObj        : { is: 'ro', init: function () { return this.taxon() }},
      removeImagePath: { init: 'project_taxon_image_path' },
      galleryWidth   : { is: 'ro', init: 650 },
      galleryHeight  : { is: 'ro', init: 250 }
    },
    methods: {
      removeImagePath: function (id) {
        return this.route(this._removeImagePath, { taxon_id: this.params().id, id: id });
      }
    }
  })
});