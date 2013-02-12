(function () {
  var Tolkin_Default_Initializer = function initialize (paras) {
    var me = this;
    if(this.meta.isAbstract) {
      var name = this.meta.className();
      throw ""+name+" is an abstract class and may not instantiated."
    }
    
    var attributes = this.meta.getAttributes();
    var attrsToInit = Object.clone(attributes);

    // init attributes with provided params first
    for(var paramName in paras) {
      var attr = this.meta.getAttribute(paramName);
      attr.doInitialization(me, paras);
      delete attrsToInit[paramName];
    }

    // init attributes for which params have not been provided afterwards
    for(var i in attrsToInit) {
      if(attributes.hasOwnProperty(i)) {
        attr = attributes[i];
        attr.doInitialization(me, paras);
      }
    }
  }

  Joose.Class.prototype.initializer = function () {
    return Tolkin_Default_Initializer;
  }
})()
