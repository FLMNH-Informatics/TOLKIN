//= require <uploader/show_new_upload>
//= require <page>

JooseModule('Collections', function (){
  JooseClass('ShowNewUploadPage',{
    isa:  Page,
    does: ShowNewUpload,
    has: {
      canRender: {is: 'ro', init: false}
    }
  })
})