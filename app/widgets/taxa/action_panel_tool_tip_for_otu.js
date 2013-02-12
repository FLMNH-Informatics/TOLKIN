//= require <widgets/templates/tooltip>
////= require <taxon>
//= require <widget>


Module('Taxa', function () {
  JooseClass('ActionPanelToolTipForOtu', {
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
//              $H(this.catalog_obj().collection()._searchParams).each(function(param) {
//                 var input = document.createElement("input");
//                 input.name = 'search['+param.key+']';
//                 input.type = "hidden";
//                 input.value = param.value;
//                $(this.id()).down('form').appendChild(input);
//               },this);
//               if(this.catalog_obj().selected().toString().length > 0){
//                  var input = document.createElement("input");
//                  input.name = 'conditions';
//                  input.type = "hidden";
//                  input.value = this.catalog_obj().selected().toString();
//                  $(this.id()).down('form').appendChild(input);
//               }
//                event.stop();
//                $(this.id()).down('form').submit();
            var match = this.catalog_obj().selected().toString().match(/^([\d,]+)\[taxon_id\]/)
            if (match) {
              params['treeViewSelected'] = match[1]
              if(params['treeViewSelected']) {
                var item_type ={
                    taxa_ids_for_otu: params['treeViewSelected'],
                    otu_name: event.element().otu_name.value
                 }
                 event.stop();
                var action_panel = this
                action_panel.notifier().working('Adding current selection to Otus ...');
                new Ajax.Request("/projects/" + params['project_id'] + "/taxa/add_to_otu", {
                  method: 'post',
                  parameters:item_type ,
                  onSuccess: function(transport) {
                   action_panel.notifier().success('Current Selection added to Otus');
                  },
                  onFailure: function() {
                    action_panel.notifier().success('problem adding otus');
                  }
                });
                  } else {
                this.notifier().working('Please check taxa to add to Otu.');
              }
            }

        }
    }
  })
});
