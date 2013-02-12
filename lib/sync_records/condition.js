JooseModule('SyncRecords', function () {
  JooseClass('Condition', {
    has: {
      subj: { is: 'ro', required: true, nullable: false },
      prop:  { is: 'ro', required: true },
      obj: { is: 'ro', required: true, nullable: false }
    },
    methods: {
      and: function (condition) {
        return new SyncRecords.Condition({ subj: this, prop: 'and', obj: condition })
      },
      toQueryString: function () {
        if(this._prop == 'eq' || this._prop == 'matches') {
          return (''+this._obj+'['+this._subj+']')
        } else if(this._prop == 'and') {
          return [ this._subj, this._obj ].join('+')
        } else {
          return null
        }
      },
      toString: function () {
        return this.toQueryString()
      }
// TODO : BEING USED???
//      merge: function (condition) {
//        if(this.subj() == condition.subj() && this.prop() == condition.prop()) {
//          var myVal = this.obj(), newVal = condition.obj();
//          if(myVal == null) {
//            this._obj = (typeof newVal == 'object') ? Object.clone(newVal) : newVal;
//          } else if(newVal == null) {
//            // do nothing
//          } else {
//            switch(typeof myVal) {
//              case 'number':
//                switch(typeof newVal) {
//                  case 'number':
//                    this._obj = {};
//                    this.obj()[myVal.toString()] = myVal;
//                    this.obj()[newVal.toString()] = newVal;
//                    break;
//                  case 'string':
//                    this._obj = {};
//                    this.obj()[myVal.toString()] = myVal;
//                    this.obj()[newVal.toString()] = newVal;
//                    break;
//                  case 'object':
//                    this._obj = Object.clone(newVal);
//                    this.obj()[myVal.toString()] = myVal;
//                    break;
//                }
//                break;
//              case 'string':
//                switch(typeof newVal) {
//                  case 'number':
//                    this._obj = {};
//                    this.obj()[myVal] = myVal;
//                    this.obj()[newVal.toString()] = newVal;
//                    break;
//                  case 'string':
//                    this._obj = {};
//                    this.obj()[myVal] = myVal;
//                    this.obj()[newVal] = newVal;
//                    break;
//                  case 'object':
//                    this._obj = Object.clone(newVal);
//                    this.obj()[myVal] = myVal;
//                }
//                break;
//              case 'object':
//                switch(typeof newVal) {
//                  case 'number':
//                    this.obj()[newVal.toString()] = newVal;
//                    break;
//                  case 'string':
//                    this.obj()[newVal] = newVal;
//                    break;
//                  case 'object':
//                    this._obj = Object.clone(newVal);
//                    Object.extend(this.obj(), myVal);
//                }
//            }
//          }
//        } else {
//          throw "trying to merge two unlike conditions"
//        }
//      }
    }
  })
});