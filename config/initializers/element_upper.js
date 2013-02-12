Element.prototype.upper = function (cssRule) {
  if(this.match(cssRule)) {
    return this;
  } else {
    return this.up(cssRule);
  }
}