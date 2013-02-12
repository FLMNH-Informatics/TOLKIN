//= require <exception>

/** section: Exception
 *  class Exception.NoMethodError < Exception
 *
 *  Error message object to be used when a method needs to be called that does
 *  not exist.  `Exception.NoMethodError` is a subclass of [[Exception]].
**/
Module('TOLJS.exception', function() {
  JooseClass('NoMethodError', {
    isa: TOLJS.Exception,
    methods: {
      /**
       *  Exception.NoMethodError#toString() -> String
       *
       *  Returns String containing _message_ and identifying this as a
       *  `Exception.NoMethodError`.
      **/
      toString: function() {
        return "NoMethodError" + (this.message ? ": " + this.message + "." : ".");
      }
    }
  })
});

