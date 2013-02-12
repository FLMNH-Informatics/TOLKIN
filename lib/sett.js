JooseClass('Sett', {
  has: {
    hash: { init: function () { return {} } }
  },
  methods: {
    add: function (item) {
      this._hash[item] = true;
      return item;
    },
    remove: function (item) {
      delete this._hash[item];
      return item;
    },
    includes: function (item) {
      return(this._hash[item] ? true : false);
    },

    toString: function () {
      return Object.keys(this._hash).join(',');
    },
    size: function () {
      return Object.keys(this._hash).size();
    },
    clear: function () {
      this._hash = {};
    },
    find: function(id){
      if (this._hash[id]){
         return true;
      } else{
          return false;
      }

    }
  }
});
