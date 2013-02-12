/* 
 *Currenty being used in at least app/widgets/new_window.js
 */
Element.addMethods('iframe', {
document: function(element) {
  element = $(element);
  if (element.contentWindow)
      return element.contentWindow.document;
  else if (element.contentDocument)
      return element.contentDocument;
  else
      return element.document;
},
$: function(element, frameElement) {
  element = $(element);
  var frameDocument = element.document();
  if (Object.isString(frameElement))
      frameElement = frameDocument.getElementById(frameElement);
  return frameElement;
}
});

