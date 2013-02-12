//= require <messages/loaded>
//= require <roles/stateful>
//= require <state>

JooseClass('RecordSet', {
  does: Stateful,
  has: {
    initial: { is: 'ro' },
    owner:   { is: 'ro', required: true, nullable: false },
    loaded:  { is: 'ro', init: false },
    records: { is: 'ro', init: function () { return $H() }},
    states:  { is: 'ro', init: function () { return new $States([
      [ 'unloaded', 'loading', 'loaded' ]
    ], this)}},
    handlers: { is: 'ro', init: function () {
      return $Handlers([], this)
    }}
  },
  after: {
    
    initialize: function () {
      this.setState('unloaded');
      this._records.update(this.initial())
      this._records.keys().each(function (key) {
        if(this._records.get(key).init) { // take care of delayed init scenario in the case of SyncProxy and such
          this._records.set(key, this._records.get(key).init.apply(this._owner, [this]))
        }
        var record = this._records.get(key)
        this.handlers().push(
          record.on('state:loading', function () { // need this to stall view render when element of record set is reloaded
            this.setState('loading')
          }, this),
          record.on('state:loaded', this._recordLoaded.bind(this))
        )
       
      }, this)
    }
  },
  methods: {
    unloadAll: function () {
      this.records().values().each(function (r) { r.unload() })
      this.setState('unloaded')
    },
    

    state: function () {
      return this.states()
    },

    each: function (func, context) {
      return this._records.values().each(func, context);
    },

    initRecords: function () {
      this._load(function (record) { 
        if (record.state().not('loaded')) { 
          if(!record.initLoader()) { record.load() } 
        }
      })
    },

    _load: function (loadFunc) {
      this.setState('loading');
      if(this._records.size() > 0) {
        this._records.values().each(function(r) {
//          var record = this._records.get(key)
          loadFunc(r) // record will load by another method if given initLoader
          
        }, this)
      }
    },

    load: function () {
      this._load(function (record) { if(!record.initLoader()) { record.load() } })
    },

    _recordLoaded: function () {
      var allLoaded = this._records.values().all(function (record) {
        return record.state().is('loaded');
      }, this);
      if(allLoaded) {
        this.setState('loaded');
      }
    },

    get: function (key) {
      return this._records.get(key);
    }//,

//    _recordLoaded: function () {
//      this._recordsToLoad--;
//      if(this._recordsToLoad == 0) { this._loaded = true }
//      new Messages.Loaded({ sender: this, receiver: this.owner() }).send();
//    }
  }
})

$RSet = function (hash, owner) {
  return new RecordSet({ initial: hash, owner: owner })
}
$Records = $RSet


