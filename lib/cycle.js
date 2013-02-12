/** section: General
 *  class Cycle
**/
Module('TOLJS', function() {
  JooseClass('Cycle', {
    has: {
      _cycle: {
        init: 1
      }
    },
    methods: {
      toString: function() {
        var out = this._cycle ? 'even' : 'odd';
        this._update();
        return out;
      },

      reset: function() {
        this._cycle = 1;
      },

      _update: function() {
        this._cycle = this._cycle ? 0 : 1
      }
    }
  })
});
