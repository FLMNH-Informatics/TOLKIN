String.prototype._underscore = String.prototype.underscore
String.prototype.underscore = function () {
  return this.split('.').collect(function (part) { return part._underscore() }).join('/')
}

