//= require <widget>

JooseModule('Templates', function () {
  JooseClass('ActionPanel', {
    isa: Widget,
    has: {
      buttons: { is: 'ro', required: true, nullable: false }
    },
    after: {
      initialize: function () {
        this.handlers().push(
          this.iMode().on('change', function () {
            this.templates().on('state:loaded', function () {
              this.refresh();
              $(this.catalog().id()).down('.selected_count').update(this.catalog().selected().size()+' selected');
              if (this.catalog().selected().size() > 0){this.catalog().showSelectionTools();}else{this.catalog().hideSelectionTools()}
            }, { once: true }, this)
          }, this)
        )
      }
    },
    methods: {
      renderToString: function () {
        return this.render()
      },


      render: function () {
        var buttonsHTML = this.buttons().inject('', function (out, buttonObj) {
          if(!buttonObj['imode'] || [ buttonObj['imode'] ].flatten().include(this.interactMode().get())) {
            //button instead of tables and spans
            var buttonTag = "<input type='button' value='" +
                            buttonObj['label'] + "' "+
                            (buttonObj['img'] ? "class='button_img' style='background-image: url("+buttonObj['img']['src']+"); '" : '')+
                            "/>"
            return(out + buttonTag)
          } else {
            return out
          }
        }, this)
        return("" +
          "<div id='"+this.id()+"' class='widget action_panel bar' "+(buttonsHTML.blank() ? "style='display:none'": '')+">" +
            buttonsHTML +
          '<span id="selected_tools" class="selected_tools" ></span>'+
          '<span class="selected_count" ></span>'+
          "</div>"
        )
      },

      requireSelection: function(fn){
        if (this.catalog()){
          if (this.catalog().selected().empty()){
            this.notifier().warn('You must select at least one item to complete this action.');
          }else{
            fn.call(this);
          }
        }else{ this.notifier().error('Missing catalog: you must declare a catalog in the action panel like -> (has: { catalog: {is: ro init: function(){return this.parent()}}}. ')}
      },
      confirmSelection: function(fn){ this.requireSelection(fn)},
      confirmSelected:  function(fn){ this.requireSelection(fn)}
    }
  })
});

