// cache initial javascript events for later processing
EVENTS_CACHE = { 
  cache: [],
  element: document.getElementsByTagName('html')[0],
  listeners: [
//    function (event) { EVENTS_CACHE.cache.push(['change',event]); },
    function (event) { EVENTS_CACHE.cache.push(['click',event]); },
//    function (event) { EVENTS_CACHE.cache.push(['submit',event]); }
  ]
};
EVENTS_CACHE.stopListening = function () {
//  EVENTS_CACHE.element.removeEventListener('change', EVENTS_CACHE.listeners[0], false);
  EVENTS_CACHE.element.removeEventListener('click', EVENTS_CACHE.listeners[0], false);
//  EVENTS_CACHE.element.removeEventListener('submit', EVENTS_CACHE.listeners[2], false);
}
EVENTS_CACHE.startListening = function () {
//  EVENTS_CACHE.element.addEventListener('change', EVENTS_CACHE.listeners[0], false);
  EVENTS_CACHE.element.addEventListener('click', EVENTS_CACHE.listeners[0], false);
//  EVENTS_CACHE.element.addEventListener('submit', EVENTS_CACHE.listeners[2], false);
}
EVENTS_CACHE.startListening();