function s(event,statesArray){
  var x=0;
  var y=0;
  var h;
  var mouseAbsPosX = Event.pointerX(event);
  var mouseAbsPosY = Event.pointerY(event);

  var message = "";
  statesArray.each(function(state, index) {
    message += index + " : " + state + "<br />";
  });

  var m = $('tooltip');
  m.style.left= mouseAbsPosX - 45 + 'px';
  m.style.top= mouseAbsPosY - 245 + 'px';
  m.innerHTML=message;
  m.style.display="block";
  m.style.zIndex=203;

}
function h(){
  var m;m=document.getElementById('tooltip');m.style.display="none";
}