//= require <widget>
//= require <roles/notifiable>
//= require <roles/polling>

/** section: Widgets
 *  class Toast
 *
 *  Notice box which will pop up on the screen with a provided message for a
 *  given amount of time when notified.  This class contains a PeriodicalExecuter
 *  that runs once a second to remove messages from the screen after they have
 *  expired.
 *
**/
Module('Widgets.Templates', function () {
  JooseClass('Toast', {
    isa: Widget,
    does: [ TOLJS.role.Notifiable, Polling ],
    methods: {
      /**
       *  Toast#error(message) -> undefined
       *  - message (String): message to display
       *
       *  Display given message on the screen with an error tone.
      **/
      error: function(message) {
        $(this.id()).down('.contents').update("<img src='/images/red-octagon-x.png' width='42px' height='42px' /><span class='notice problem'>Error: " + message + "</span>");
        this.appear();
      },

      failure: function (message) { return this.error(message); },

      /**
       *  Toast#expireMessages() -> undefined
       *
       *   Remove messages which have exceeded their display time from the screen.
      **/
      expireMessages: function() {
        if(this._displayForTime && ( new Date().getTime() > (this._displayStart + (this._displayForTime * 1000)))) {
          this._displayForTime = null;
          this.fade();
        }
      },

      /**
       *  Toast#handleEvent(event) -> undefined
       *  - event (Event): the event to be handled
       *
       *  Responds to event provided with the appropriate method.  Currently this is
       *  only handling the event for widget hiding.
      **/
      onClick: function(event) {
        Event.delegate({
          ".close_button": function() {
            this.fade();
          },
          "#copy_matrix": function(){
            var type = params["controller"].sub('/','_').singularize();
            if (confirm('Copy this date into usable matrix?')){
              this.parent().widgets().get('window').loadPage('show_copy_matrix_project_' + type + '_path', {date: params["date"]})
            }
          }
        }).bind(this)(event);
      },
      expire: function (expireTime){
        expireTime = (typeof expireTime === "undefined") ? 2500 : expireTime;
        var showTime = new Date().getTime();
        this.poll({
          on:  function () { return new Date().getTime() - showTime >= expireTime },
          run: function () { this.hide() }
        })
      },

      /**
       *  Toast#success(message) -> undefined
       *  - message (String): message to display
       *
       *  Display given message on the screen with a success tone.  Message displays
       *  for two seconds.
      **/
      success: function(message) {
//        this._displayStart = new Date().getTime();
//        this._displayForTime = 2;
        $(this.id()).down('.contents').update("<img src='/images/check.png' width='42px' height='42px' /><span class='notice success'>"+(message||"Operation successful.")+"</span>");
        this.appear(); // don't remove me - ChrisG
        this.expire();
      },

      /**
       *  Toast#hide() -> undefined
       *
       *  Hide this widget with a fade event.
      **/
      hide: function() {
        $(this.id()).hide();
      },

      fade: function () {
        $(this.id()).fade({duration: 0.3});
      },

      appear: function () {
        $(this.id()).appear({duration: 0.2});
      },

      /**
       *  Toast#show() -> undefined
       *
       *  Show this widget.
      **/
      show: function() {
        $(this.id()).show();
      },

      warning: function(message) {
        $(this.id()).down('.contents').update("<table><tr><td><img src='/images/warning-triangle.png' /></td><td class='notice warning'>" + message + "</td></tr></table>");
        this.appear();
      },
      warn: function(message) {
        $(this.id()).down('.contents').update("<table><tr><td><img src='/images/warning-triangle.png' /></td><td class='notice warning'>" + message + "</td></tr></table>");
        this.appear();
        this.expire();
      },
      notify: function(message){
        $(this.id()).down('.contents').update("<table><tr><td><img src='/images/msg_icon.jpg' /></td><td class='notice warning'>" + message + "</td></tr></table>");
        this.appear();
        this.expire(150000);
      },
      customMessage: function(message, url){
        var url = url ? url : ""
        $(this.id()).down('.contents').update("<table><tr><td><img src='" + url + "' /></td><td class='notice warning'>" + message + "</td></tr></table>");
        this.appear();
        this.expire();
      },

      /**
       *  Toast#working(message) -> undefined
       *  - message (String): message to display
       *
       *  Display given message on the screen with a working tone.
      **/
      working: function(message) {
        $(this.id()).down('.contents').update("<img src='/images/ajax-loader-large.gif' /><span class='notice'>"+(message||"Working ...")+ "</span>");
        this.appear();
      }
    }
  })
});