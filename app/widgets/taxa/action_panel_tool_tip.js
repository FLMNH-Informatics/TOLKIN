//= require <widgets/templates/tooltip>
////= require <taxon>
//= require <widget>


Module('Taxa', function () {
  JooseClass('ActionPanelToolTip', {
    isa:  Templates.Tooltip,
    has: {
      catalog_obj: {is: ro , init:''},
      container: { is: 'ro', init: ""},
      closeButton:    { is: 'rw', init: 'X' },
      styles: {init: 'height: 500px; width: 200px;'}

    },
//    override: {
//      toString: function () {
//        return this.SUPER();
//      }
//    },
    methods: {       
       onChange: function(event) {
          Event.delegate({
          "input.check_all": function (event) {
            var chkbox_list = $(this.id()).down('form').elements['select[]']
            if($F(event.element())) {
                 
                for(var i = 0; i < chkbox_list.length ; i++)
            			chkbox_list[i].checked = true;

            } else {
              for(var i = 0; i < chkbox_list.length ; i++)
            			chkbox_list[i].checked = false;
            }
//            this.selected().where().clear();
//            this.selected().where(this.collection().where());
          },
           "input[type='checkbox']" : function (event) {
             if($(this.id()).down('.check_all').checked){
               $(this.id()).down('.check_all').checked = false;
             }
           }
          
          }).bind(this)(event);
         
       },
       
       onSubmit:function(event){
              $H(this.catalog_obj().collection()._searchParams).each(function(param) {
                 var input = document.createElement("input");
                 input.name = 'search['+param.key+']';
                 input.type = "hidden";
                 input.value = param.value;
                $(this.id()).down('form').appendChild(input);
               },this);
               if(this.catalog_obj().selected().toString().length > 0){
                  var input = document.createElement("input");
                  input.name = 'conditions';
                  input.type = "hidden";
                  input.value = this.catalog_obj().selected().toString();
                  $(this.id()).down('form').appendChild(input);
               }
                event.stop();
                $(this.id()).down('form').submit();
        }
    }
  })
});
