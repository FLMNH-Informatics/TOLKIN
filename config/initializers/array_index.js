Array.prototype.index = function (iterator, context) {
  for(var i in this) {
    if(iterator(this[i])) { return i; } // TODO: context is not handled
  }
  return null;
}