/** section: Exception
 *  class Exception
**/
Module('TOLJS', function() {
  JooseClass('Exception', {
    has: {
      backtrace: {
        isa: rw,
        init: null
      }
    },
    methods: {
      initialize: function(msg) {
        this.message = msg;
        this.backtrace = "";
      },
      toString: function() {
        return "An exception has been raised" + (this.message ? ": " + this.message + "." : ".");
      }
    }
  })
});


