//= require <templates/image_gallery>

JooseModule('Morphology.Matrices.Cells', function () {
  JooseClass('ImageGallery', {
    isa: Templates.ImageGallery,
    has: {
      cell: { is: 'ro', required: true, nullable: false },
      joinObj: { is: 'ro', init: function () { return this.cell() }},
      joinClassname: { is: 'ro', init: 'Morphology.Matrices.Cell' },
      removeImagePath: { is: 'ro', init: 'project_image_join_path' },
      galleryWidth   : { is: 'ro', init: 450 },
      galleryHeight  : { is: 'ro', init: 275 }
    }
  })
});