function positionWindow(elementID) {

  var viewDimensions = document.viewport.getDimensions();
  var offsetFromView = $(elementID).viewportOffset();
  var elemDimensions = $(elementID).getDimensions();
  var positionedOffset = $(elementID).positionedOffset();

  // calculate necessary reposition from current position
  // to bring upper left corner of window to center of viewport
  var centerX = (viewDimensions.width / 2) - offsetFromView.left;
  var centerY = (viewDimensions.height / 2) - offsetFromView.top;

  // factor in half of window width and height so that
  // center of window is brought to center of viewport
  var leftOffset = centerX - (elemDimensions.width / 2);
  var topOffset =  centerY - (elemDimensions.height / 2);

  // position of window is a combination of current location
  // and calculated position change
  var finalOffsetY = topOffset + positionedOffset.top;
  var finalOffsetX = leftOffset + positionedOffset.left;

  $(elementID).style.top = finalOffsetY + "px";
  $(elementID).style.left = finalOffsetX + "px";
}

function setWindowSize(elementID, X, Y)
{

  element = document.getElementById(elementID);
  element.style.width = X + "px";
  element.style.height = Y + "px";
}

function showWindow(elementId) {
  $(elementId).show();
  positionWindow(elementId);
}

function hideWindow(elementID)
{
  document.getElementById(elementID).hide();
}

function getSelectedElementValues(element_name)
{
  var elements=document.getElementsByName(element_name);
  var selectedElements = "";

  for(i=0; i<elements.length; i++)
  {
    if (elements[i].checked)
    {
      selectedElements += elements[i].value + " ";
    }
  }
  return selectedElements;
}

function setElementValue(element_id, value)
{
  var element = document.getElementById(element_id);
  element.value = value;
}
