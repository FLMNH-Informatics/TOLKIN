//= require "frame"
//= require <roles/polling>
//= require <roles/fires_events>

/** section: Widget
 *  class Window
 *
 *  Abstract class which can be subclassed to create standard draggable and
 *  closeable windows.  Subclass needs to provide the 'title' parameter to
 *  display as the window title, and should provide contents for the render
 *  method to display.
 *  
 **/
Module('Templates', function() {
  JooseClass('Window', {
    isa: Templates.Frame,
    does: [ Polling, Roles.FiresEvents ],
    has: {
      content: { is: 'ro' },
      title: { is: 'rw', init: null },
      closeButton: {
        is: 'rw',
        init: 'X'
      },
      windowTemplate: {
        is: 'rw',
        lazy: true,
        init: function() {
          return this.parent().templates()
        }
      },
      width:  {
        is: 'ro',
        init: null
      },
      height: {
        is: 'ro',
        init: null
      },
      winjs:  {
        is: 'ro'
      },
      visible: {
        is: 'ro'
      },
      onLoadQueue: { }//,
//      handlers: {
//        is: 'ro',
//        init: function () {
//          return $Handlers([
//            
//        }
//      }
    },
    after: {
      initialize: function () {
        this.handlers().push(
          this.on('historyUpdate', (function () {
            var element;
            if((element = $(this.id()).down('.back.button.inactive'))) {
              if(!this._history.empty()) {
                element.removeClassName('inactive');
              }
            } else {
              if(this._history.empty()) {
                element = $(this.id()).down('.back.button');
                element.addClassName('inactive');
              }
            }
          }).bind(this))
        )
        var me = this;
        var element = $(this.id());
        this._visible = element && element.visible();
      //        this.poll({
      //          on: function () {
      //            return this.interactMode().get()
      //          },
      //          run: function () {
      //            this.interactMode().addObserver(this, function () {
      //              if(this.page()) {
      //                if (!$(this.id()).down('.page-throbber')) { // if page is still loading, don't try to render prematurely
      //                  this.page().state().set('loading')
      //                  this.page().onLoad()
      //                  this.render()
      //                  this.refresh()
      //                }
      //              } else {
      //                me.render();
      //                if(me._visible) {
      //                  me.refresh();
      //                }
      //              }
      //            })
      //          }
      //        })
      },
      loadPage: function () {
        if (this.render()) {
          this.display()
        }
      }
    },
    override: {
      /**
       *  Window.onClick() -> undefined
       *
       *  Event handler for click events occurring on visible window.
       **/
      onClick: function(event) {
        var me = this;
        Event.delegate({
          '.back.button': function () {
            if(!event.element().hasClassName('inactive')) {
              me.back();
            }
          },
          '.close_button' : function(event) {
            me.close();
          },
          '.publicityButton': function (event) {
            var ids = this.params.id
              , path = this.params.controller
              , action;
            switch(event.element().value){
              case "Make Record Public":       action = "make_public";       break;
              case "Make Record Private":      action = "make_private";      break;
            }
            if (confirm("Do you want to " + event.element().value.toLowerCase() + "?")){
              publify(me,params["project_id"],ids,path,action, "Successfully " + event.element().value.toLowerCase().sub("k","d") +".", function(){
                $('publicityButton').value = event.element().value == "Make Record Public" ? "Make Record Private" : "Make Record Public";
              });
            }
          }
        })(event);
        this.SUPER && this.SUPER(event);
      },

      /**
       *  Window.render(contents) -> undefined
       *  - contents (String): Contents to be rendered within the window.
       *
       *  Renders this window on the page with the contents provided.  If a window
       *  is already being displayed with the same id, that window is replaced with
       *  the newly rendered window, which is positioned on screen at the same
       *  location as the old window.
       **/
      render: function(options) {
        if(this.page && this.page()) {
          this._width || (this._width = this.page().width());
          this._height || (this._height = this.page().height());
          this._title  = this.page().title()
        }
        this._width  = this._width  || (document.viewport.getWidth() / 2);
        this._height = this._height || (document.viewport.getHeight() / 2);

        options = options || {};

        var pageLoaded = !this.page || !this.page() || this.page().state().is('loaded') ? true : false;
        if(this.page()) {
          if(!options.yield) {
            options.yield = pageLoaded ?
            (this.page().renderToString && this.page().renderToString())
            || (this.page().render && this.page().render()) : this.throbber();
          }
        } else {
          options.yield || (options.yield = this._rendered) || this.throbber(); // if nothing to render given, simply rerender previous view
        }
        this._rendered = options.yield;
        this.state().set(pageLoaded ? 'pageRendered' : 'loadRendered');
        return this._rendered
      }
    },

    methods: {
      throbber: function () {
        return (
          "<img "+
          "style='"+
          "position: absolute;"+
          "left:"+(this._width/2)+"px; "+
          "top:"+(this._height/2)+"px;"+
          "' "+
          "src='"+(params['path_prefix']||'')+"/images/ajax-loader-large-alt.gif' "+
          "class='page-throbber' "+
          "/>"
          )
      },
      
      _display: function () {
        var me = this;
        this._winjs = Windows.getWindow(this.id());
        if(!this.winjs()) {
          this._winjs = new Window({
            id: this.id(),
            className: "tolkinlighting",
            addClassNames: "widget",
            parent: 'viewport',
            zIndex: 2000,
            showEffectOptions: {
              duration: 0.3
            },
            hideEffectOptions: {
              duration: 0.3
            },
            title: this.title(),
            width: this._width,
            height: this._height,
            destroyOnClose: true,
            onClose: function () {
              me._visible = false;
              if(me._page) {
                me.unloadPage();
              } else {
                me.unload(); // for custom window objects, make sure to unload object when close button pressed
              }
              delete me._width; // have to delete width and height so that render will reset when next page loaded
              delete me._height;
            },
            onResize: function () {
              me._width  = me._winjs.width;
              me._height = me._winjs.height;
            }
          })
        }
        this.winjs().setTitle(this._title);
        this._winjs.setCreateCopyButton(
          (
            (this.interactMode() == 'edit')
            && (this._page ? this._page._createCopy : this._createCopy)
          ) || false
        )
        this.iMode().on('state:loaded', function () { 
          this._winjs.setSaveButton(
            (
              (this.interactMode() == 'edit')
              && (this._page ? this._page.savable() : this._savable)
            ) || false , (this._page ? this._page.saveButtonText() : this._saveButtonText) || 'Save'
          );
          //get correct public button option
//          if (me.interactMode() == "edit"){
//            publifyStatus(params["project_id"],params["controller"],"get_public_status",params["id"], function(status){
//              if(typeof(status) == "boolean"){
//                //me._winjs.setPublicityButton((me.interactMode() == 'edit') || false, status ? "Make Record Private" : "Make Record Public")}
//            });
//          }
        }, { once: true }, this)
        this.winjs().setSize(this._width, this._height);
        this.winjs().setHTMLContent(this._rendered);
        if(!this._visible) { // only call show (and showCenter on window_js object) if needed
          this.show();
          this._visible = true;
        }
      },

      showSaveButton: function () {
        this.winjs().setSaveButton(true, (this._page ? this._page.saveButtonText() : this._saveButtonText) || 'Save');
      },

      templates: function () {
        return this.parent().templates();
      },

      notifier: function () {
        return this.parent().notifier();
      },

      interactMode: function () {
        return this.parent().interactMode();
      },

      /**
       *  Window.center() -> undefined
       *
       *  Centers currently displayed window in user viewport.
       **/
      center: function() {
        var element = $(this.id());
        var viewDimensions = document.viewport.getDimensions();
        var offsetFromView = element.viewportOffset();
        var elemDimensions = element.getDimensions();
        var positionedOffset = element.positionedOffset();

        // calculate necessary reposition from current position
        // to bring upper left corner of window to center of viewport
        var centerX = (viewDimensions.width / 2) - offsetFromView.left;
        var centerY = (viewDimensions.height / 2) - offsetFromView.top;

        // factor in half of window width and height so that
        // center of window is brought to center of viewport
        var leftOffset = centerX - (elemDimensions.width / 2);
        var topOffset =  centerY - (elemDimensions.height / 2);

        // position of window is a combination of current location
        // and calculated position change
        var finalOffsetY = topOffset + positionedOffset.top;
        var finalOffsetX = leftOffset + positionedOffset.left;

        element.setStyle({
          left: finalOffsetX + "px",
          top: finalOffsetY + "px"
        });
      },
      /**
       *  Window.close() -> undefined
       *
       *  Hides visible window.
       **/
      close: function() {
        this.winjs().close();
        return this;
      },

      //      /**
      //       *  Window.onClick() -> undefined
      //       *
      //       *  Event handler for click events occurring on visible window.
      //       **/
      //      onClick: function(e) {
      //        var window = this;
      //        Event.delegate({
      //          '.close_button' : function(e) {
      //            window.close();
      //          }
      //        })(e);
      //      },

      onSubmit: function(event) {
        if(this.page() && this.page().onSubmit) {
          this.page().onSubmit(event);
        }
      },

      /**
       *  Window.notify(message) -> Boolean
       *  - message (String): Message to be displayed.
       *
       *  Displays provided message in a special notice area on the window.
       **/
      notify: function(message) {
        if($(this.id())) {
          $(this.id()).down('.notice_area').update(message);
          return true;
        } else {
          return false;
        }
      },

      postRender: function () {
        if(this.page() && this.page().postRender) {
          this.page().postRender()
        }
      },

      renderAndShow: function (options) {
        this.render(options);
        this.show();
      },

      //      receiveMessage: function (message) {
      //        switch(message.meta.className()) {
      //          case 'Messages.Loaded':
      //            if(message.sender() == this.page()) {
      //              execQueue('onLoadQueue');
      //            }
      //        }
      //      },

      show: function () {
        this.winjs().showCenter();
        this._visible = true;
        return this;
      //        if(!$(this.id()).visible()) {
      //          Effect.Appear(this.id(), { duration: 0.2 });
      //        }
      },

      toFront: function () {
        this.winjs().toFront();
        return this;
      }//,

    //      _insertAndPosition: function(evaluated) {
    //        if($(this.id())) {
    //          var oldLeft = $(this.id()).getStyle('left');
    //          var oldTop = $(this.id()).getStyle('top');
    //          var cumulativeTop = $(this.id()).cumulativeOffset().top;
    //          var oldHeight = $(this.id()).getHeight();
    //          $(this.id()).replace(evaluated); // replace old window if its there
    //          // place window at old position only if old position is still in viewport
    //          if(cumulativeTop < document.viewport.getScrollOffsets()[1] ||
    //            cumulativeTop + oldHeight > document.viewport.getScrollOffsets()[1] + document.viewport.getHeight()) {
    //            this.center();
    //          } else {
    //            $(this.id()).setStyle({
    //              left: oldLeft,
    //              top: oldTop
    //            });
    //          }
    //        } else {
    //          $('viewport').insert({
    //            bottom: evaluated
    //          });
    //          this.center();
    //        }
    //      }
    }
  })
});
