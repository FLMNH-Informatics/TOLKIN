JooseClass('Queue', {
  has: {
    array: { init: function () { return [ ] } } },
  methods: {
    empty: function () { // queue.is_empty?
      return(this._array.size() == 0)
    },

    clear: function () { // clear / empty the queue
      this._array = [];
    },

    add: function (func) {
      this._array.push(func) },

    flush: function (id) {
      var first = this._array.first();
      if(first) {
        if(id && first.ids) {
          first.ids.set(id, first.ids.get(id) - 1);
          if(first.ids.get(id) == 0) { first.ids.unset(id) }
          if(first.ids.size() == 0) { delete first.ids } }
        while(this._array.first() && !this._array.first().ids) { // when there is not a join blocking the queue, push forward
          this._array.shift()() } } },

    join: function () {
      var args = [ [].splice.call(arguments, 0) ].flatten();
      var funcToAdd = function () { } // okay that function is empty - is just a placeholder for join ids
      funcToAdd.ids = $H();
      args.each(function(id) {
        if(id) {
          funcToAdd.ids.set(id, (funcToAdd.ids.get(id) || 0) + 1) 
        } })
      if(funcToAdd.ids.size() == 0) { delete funcToAdd.ids }
      this._array.push(funcToAdd) } } })
