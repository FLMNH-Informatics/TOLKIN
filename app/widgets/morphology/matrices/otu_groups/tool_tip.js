//= require <templates/tooltip>
//= require <taxon>
//= require <widget>



Module('Widgets.Morphology.Matrices.OtuGroups', function () {
  JooseClass('ColorPickerToolTip', {
    isa:  Templates.Tooltip,
    has: {
      catalog_obj: {is: ro , init:''},
      container: { is: 'ro', init: ""},
      closeButton:    { is: 'rw', init: 'X' },
      record:{init:''},
      styles: {init: 'height: 500px; width: 200px;'},
      context: {}

    },
    after:{
      initialize:  function(){
      }
    },
//    override: {
//      toString: function () {
//        return this.SUPER();
//      }
//    },
    methods: {           
       
       onSubmit:function(event){
            event.stop();
            this._record.updateAttributes({color: $('output').value});
            
        }
    }
  })
});
