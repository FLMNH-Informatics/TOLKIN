//= require <windows_js/init>

Window.prototype.toFront = function () {
  //if (this.element.style.zIndex < Windows.maxZIndex)
      this.setZIndex(Windows.maxZIndex + 1);
    if (this.iefix)
      this._fixIEOverlapping(); 
}