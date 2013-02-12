Joose.Class.prototype.inheritsFrom = function (klass) {
  return (this.getSuperClasses().detect(function (c) { return c == klass }) ? true : false)
};