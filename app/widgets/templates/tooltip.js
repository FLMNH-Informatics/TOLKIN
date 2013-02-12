//= require <widget>

Module('Templates', function () {
  JooseClass('Tooltip', {
    isa: Widget,
    has: {
      insertUnder: { init: 'contents' },
      contents: { is: ro, init: '' },
      //container: { init: "<div id='#{tooltip_id}' class='widget tooltip' style='z-index: 3000; display: none; top: 0px; left: 0px; position: fixed;overflow: auto;'>#{content}</div>" },
      extraClasses: {init: ''},
      styles: {init: ''},
      closeButton:    { is: 'rw', init: '' }
    },
    after: {
      initialize: function () {
        $(this.viewport().id()).insert({
            bottom: this.renderToString()
        });
      }
    },
    methods: {
      onClick: function(event) {
          Event.delegate({
          ".tooltip_close": function (event) {
            this.update('');
            this.hide();
          }
          }).bind(this)(event);

       },



//      render: function () {
//
//      },

      renderToString: function () {
        return(
          "<div id='"+this.id()+"' class='widget tooltip "+this._extraClasses+"' style='z-index: 3000; display: none; top: 0px; left: 0px;position: fixed; '><span style='position:absolute; right:20px;' class='tooltip_close'>"+this._closeButton+"</span><div class='content_div' style='overflow: auto;"+this._styles+"'>"+
            this.contents()+
          "</div></div>"
        )
      },
      show: function() {
        $(this._id).style.display = 'block';
        return this
      },

      hide: function() {
        if($(this._id)) {
          $(this._id).hide();
        }
      },

      visible: function() {
        if($(this._id).visible()) {return true}
        else{return false}
      },

      move: function(pointer) {
        $(this._id).style.left = (pointer.x + 15) + 'px';
        $(this._id).style.top = (pointer.y + 15) + 'px';
        return this
      },

      update: function(contents) {
        if(this.contents != contents) {
          if(contents == '') {
            $(this._id).hide();
          } else {
            $(this._id).style.display = 'block';
          }
        }
        this.contents = contents;
        $(this.id()).down('.content_div').update(this.contents);
        return this
      }
    }
  })
});
