//= require "sett"

JooseClass('WhereConditions', {
  has: {
    collection: { is: 'ro', required: true, nullable: false },
    conditions: { init: function () { return $H() } }
  },
  after:{
    initialize: function() { }
  },
  methods: {
    '=' : function () { return this.eq() },
    '<>': function () { return this.ne() },

    eq: function (subj, obj) {
      this._conditions || (this._conditions = $H());
      var subjHash = this._conditions.get(subj) || this._conditions.set(subj, $H());
      var set = subjHash.get('=') || subjHash.set('=', new Sett());
      return set.add(obj);
    },
    ne: function (subj, obj) {
      this._conditions || (this._conditions = $H());
      var subjHash = this._conditions.get(subj) || this._conditions.set(subj, $H());
      var set = subjHash.get('=') || subjHash.set('=', new Sett());
      return set.remove(obj);
    },
    reset: function () { return this.none(); },
    clear: function () { return this.none(); },
    none: function () {
      this._conditions = null;
      this.collection()._count = 0;
    },
    all: function () {
      this._conditions = $H();
    },

    toString: function () {
      if(this._conditions === null) {
        return 'false'
      } else {
        var str = this._conditions.collect(function (pair1) {
          var subj = pair1.key;
          return pair1.value.collect(function (pair2) {
            var out = '';
            var prop = pair2.key;
            var obj = pair2.value;
            switch(pair2.key) {
              case '=':
                out += obj+'['+subj+']';
                break;
              case '<>': alert('NOT IMPLEMENTED YET'); break;
            }
            return out
          }).join('+');
        }).join('+');
        if(str == '') {
          str = 'true';
        }
        return str;
      }
    }
  }
});
