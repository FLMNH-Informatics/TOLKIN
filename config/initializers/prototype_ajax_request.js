// catch and display errors generated by ajax requests
Ajax._Request = Ajax.Request;
Ajax.Request = Class.create(Ajax._Request, {
  initialize: function($super, url, options, thisArg) {
    var onSuccess = options.onSuccess;
    var onException = options.onException;
    var optionsExtension = {
      sanitizeJSON: true,
      onSuccess: function(transport) {
        if(onSuccess) {
          try {
            onSuccess(transport);
          } catch(error) {
            //alert(error);
            init.viewport().notifier().error(error);
            throw(error);
          }
        }
      },
      onException: function(requester, error) {
        if(onException) {
          onException(requester, error)
        } else {
          throw(error);
        }
      },
      evalJS: options.evalJS || true // TURN OFF EVALUATION OF EMBEDDED JAVASCRIPT BY DEFAULT - NOT NEEDED AND RAISES ERROR MESSAGES FOR SOME RESPONSES
    };
    $super(url, Object.extend(options, optionsExtension));
  }
});
Ajax.Request.Events = Ajax._Request.Events;