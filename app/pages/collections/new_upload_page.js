//= require <page>
//= require <uploader/new_upload>

JooseModule('Collections', function (){
  JooseClass('NewUploadPage',{
    isa:  Page,
    does: NewUpload,
    has: {
      canRender: {is: 'ro', init: false},
      partialPath: {is: 'ro', init: function (){
        var splitPath = window.location.pathname.split('/').reverse();
        return (splitPath.length == 5 ? splitPath[1] : (splitPath[2] + "_" + splitPath[1]));
        }
      }
    },
    methods: {}
  })
})