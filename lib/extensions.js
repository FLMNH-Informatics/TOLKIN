Object.extend(Date, {
  format: function(iso8601) {
    var formatted;
    if(iso8601) {
      var match = iso8601.match(/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):\d{2}Z/);
      var month = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ][match[2][0] == '0' ? parseInt(match[2][1]) - 1 : parseInt(match[2]) - 1];

      formatted = "#{b} #{d}, #{Y} #{H}:#{M} #{Z}".interpolate({
        b: month,
        d: match[3],
        Y: match[1],
        H: match[4],
        M: match[5],
        Z: 'UTC'
      })
    } else {
      formatted = null;
    }
    return formatted;
  }
})

Object.extend(Array, {
  remove: function(obj) {
    var removedObj = null;
    this.each(function(arrObj, index) {
      if(arrObj == obj) {
        removedObj = this.splice(index, 1);
      }
    });
    return removedObj;
  }
});

///*
// * InPlaceEditor extension that adds a 'click to edit' text when the field is
// * empty.
// */
//Ajax.InPlaceEditor.prototype.__initialize = Ajax.InPlaceEditor.prototype.initialize;
//Ajax.InPlaceEditor.prototype.__getText = Ajax.InPlaceEditor.prototype.getText;
//Ajax.InPlaceEditor.prototype.__onComplete = Ajax.InPlaceEditor.prototype.onComplete;
//Ajax.InPlaceEditor.prototype.__wrapUp = Ajax.InPlaceEditor.prototype.wrapUp;
//Ajax.InPlaceEditor.prototype = Object.extend(Ajax.InPlaceEditor.prototype, {
//
//    initialize: function(element, url, options){
//        this.__initialize(element,url,options)
//        this.setOptions(options);
//        this._checkEmpty();
//    },
//
//    setOptions: function(options){
//        if(!this.options.externalControlOnly) {
//        this.options = Object.extend(Object.extend(this.options,{
//            emptyText: 'click to edit...',
//            emptyClassName: 'inplaceeditor-empty'
//        }),options||{});
//        } else {
//            this.options = Object.extend(Object.extend(this.options,{
//            emptyText: 'None',
//            emptyClassName: 'inplaceeditor-empty'
//            }),options||{});
//        }
//    },
//
//    _checkEmpty: function(){
//        if( this.element.innerHTML.length == 0 ){
//            this.element.appendChild(
//        Builder.node('span',{
//          className:this.options.emptyClassName
//          },this.options.emptyText));
//        }
//    },
//
//    getText: function(){
//    if (empty_span = this.element.select("." + this.options.emptyClassName).first()) {
//      empty_span.remove();
//    }
//        return this.__getText();
//    },
//
//    onComplete: function(transport){
//        this._checkEmpty();
//        this.__onComplete(transport);
//  },
//
//  wrapUp: function(transport) {
//    this.leaveEditMode();
//    this._checkEmpty(); // added by ChrisG
//    // Can't use triggerCallback due to backward compatibility: requires
//    // binding + direct element
//    this._boundComplete(transport, this.element);
//    }
//});


