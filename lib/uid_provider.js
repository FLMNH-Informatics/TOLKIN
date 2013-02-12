////= require "uid"
//
//JooseClass('UidProvider', {
//  has: {
//    min: { init: 1 },
//    max: { init: Math.pow(2,40) },
//    uidHash: { init: function () { return $H() }}
//  },
//  methods: {
//    get: function () {
//      return new Uid({ value: this._getUidNum(), provider: this });
//    },
//
//    // meant to be called by uids only
//    remove: function (uidNum) {
//      this._uidHash.unset(uidNum)
//    },
//
//    _getUidNum: function () {
//      var rand = this._randInt()
//      while(this._uidHash.get(rand.toString())) { rand = this._randInt() }
//      this._uidHash.set(rand.toString(), rand);
//      return rand;
//    },
//
//    _randInt: function () {
//      return(Math.floor(Math.random() * (this._max - this._min + 1)) + this._min)
//    }
//  }
//});