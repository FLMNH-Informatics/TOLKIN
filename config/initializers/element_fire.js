// pass all custom events through Tolkin's event handling system
(function () {
  var oldFunc = Event.fire;
  var newFunc = function (element, eventName, memo, bubble) {
    oldFunc(element, eventName, memo, bubble);
    init && init.viewport().eventRouter()._handleEvent(eventName, {
      element: function () { return element; }
    });
  };
  Event.fire = newFunc;
})();