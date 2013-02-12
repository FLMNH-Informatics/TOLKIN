 if($('project_select')) {
  $('project_select').observe('change', function(event) {
    var address = window.location.pathname.split("/")
    if(2 > address.length || address[1] == ''){
         address[1] = 'projects';
    }
    if(address[1] == 'login'){
       window.location.pathname =  address[0] + "/projects/" + $F('project_select');
    }else{
       var firstPath = "/" + address[1] + "/" + ($F('project_select'))
       window.location.pathname = address.length > 3 ? //if address length is more than 3, use the full path
          firstPath + "/" + address[3] + (address[4] && isNaN(address[4]) ? "/" + address[4] : "")  //if there's more dirs and they're not a number, add them to the path
            : firstPath //else just use the base path
    }
  });
}

function getInternetExplorerVersion()
// Returns the version of Internet Explorer or a -1
// (indicating the use of another browser).
{
  var rv = -1; // Return value assumes failure.
  if (navigator.appName == 'Microsoft Internet Explorer')
  {
    var ua = navigator.userAgent;
    var re  = new RegExp("MSIE ([0-9]{1,}[\.0-9]{0,})");
    if (re.exec(ua) != null)
      rv = parseFloat( RegExp.$1 );
  }
  return rv;
}
function checkVersion()
{
  var msg = "Tolkin does not support Microsoft Internet Explorer. ";
  var ver = getInternetExplorerVersion();


  if ( ver > -1 )
  {
    alert( msg );
  }
}
checkVersion();
