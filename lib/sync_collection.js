//= require <roles/observable>
//= require <roles/stateful>
//= require "where_conditions"
//= require <sync_records/options_hash>

// collection of results from a multi-query to an SyncRecord class.  collection
// of results is kept up-to-date and synchronized across client-app
JooseClass('SyncCollection', {
  does: [ TOLJS.role.Observable, Stateful ],
  has: {
//    id: { is: 'ro', init: function () { return this.context().uids().get() } },
    type: { is: 'ro', required: true, nullable: false },
    context: { is: 'ro', required: true, nullable: false },
    ids: { init: function () { return [] } },
    initLoader: { is: 'ro' }, // SyncCollection or SyncRecord object that will contain fetched data
    initLoaderFn: { }, // function (loaderAtts) should return simple object (hash) representing collection data
    data: { is: 'ro',
      init: null
    },
    searchParams: { },
    states: { is: 'ro', init: function () { return $States([
      [ 'unloaded', 'loading', 'loaded' ]
    ], this) } },
    finderOptions:      {
      is: 'ro',
      init: function () {
        return new SyncRecords.OptionsHash()
      }
    },
    offset:       { },
    limit:        { },
    select:       { },
    include:      { },
    order:        { },
    conditions:   { },
    search: { is: 'ro', init: function () { return {} } },
    //loading:      { is: 'ro', init: false },
    //loaded:       { is: 'ro', init: false },
    whereConditions: {
      init: function () {
        return new WhereConditions({
          collection: this
        })
      }
    },
    handlers: { is: 'ro', lazy: true, init: function () {
      var hArr = [
        this.type().on('recordCreated', this.handleEvent.bind(this)),
        this.type().on('recordUpdated', this.handleEvent.bind(this)),
        this.type().on('recordsDestroyed', this.handleEvent.bind(this))
      ]
      if(this._initLoader) {
        hArr.push(this._initLoader.on('state:loading', function () { this.setState('loading') }, { once: true }, this))
        hArr.push(
          this._initLoader.on('state:loaded', function () {
            this._data = this._initLoaderFn(this._initLoader.attributes())
            this.setState('loaded')
          }, { once: true }, this)
        )
      }
      return $Handlers(hArr, this)
      }
    }
  },
  after: {
    initialize: function () {
      if(!this._finderOptions.meta) { // wrap finderOptions in OptionsHash class if they aren't already
        this._finderOptions = new SyncRecords.OptionsHash(this._finderOptions)
      }
      if(this.data()) {
        this.setState('loaded')
      } else {
        this.setState('unloaded')
      }

      this.handlers();
      this.type().addObserver(this, this.onChange);
    }
  },
  methods: {
    state: function () {
      return this.states()
    },

    entries: function () {
      //excluded "can_publify" also, because of publifier control in catalog needing this extra attribute
      return this._data[Object.keys(this._data).without('count', 'limit', 'offset', 'can_publify').first()]
    },

    unload: function () {
      this.handlers().expireAll()
      this.setState('unloaded')
    },

    handleEvent: function (event) {
      switch(event.type()) {
        case 'recordCreated':
          this.fire('reloading');
          this.reload();
          this.fire('recordCreated', {
            memo: event.memo()
          });
          break;
        case 'recordUpdated':
          this.fire('reloading');
          var record = event.memo() && event.memo().record
          if(!record || this.contains(record)) { // update everything if record id not provided for inspection
            this.reload();
            this.fire('recordUpdated', {
              memo: event.memo()
            });
          }
          break;
        case 'recordsDestroyed':
          this.fire('reloading');
          record = event.memo();
          if(this.contains(record)) {
            this.reload();
            this.fire('recordsDestroyed', {
              memo: event.memo()
            });
          }
          break;
      }
    },

    contains: function (record) {
      // FIXME: unsure for now so passing along all - need to run tests here eventually
      return true;
    },

    size: function () {
      return this.count()
    },
    count: function () {
      return (this._data && this._data.count)
    },

    where: function (condition) {
      if(condition === undefined) {
        return this.finderOptions().conditions
      } else {
        if(condition === false || condition === 'false' || condition === null || condition === 'null') {
          this.finderOptions().conditions = false
        } else if(condition === true || condition === 'true') {
          this.finderOptions().conditions = true
        } else if(condition.meta && condition.meta.className().match(/SyncRecords/)) {
          this.finderOptions().conditions = condition
        } else {
          throw('unknown configuration of where conditions')
        }
        return this;
      }
    },

    select: function (select) {
      if(select == undefined) {
        return this._finderOptions.select
      } else {
        this._finderOptions.select = Array.prototype.slice.call(arguments).flatten()
        return this
      }
    },

    joins: function (joins) {
      if(joins == undefined) {
        return this._finderOptions.joins
      } else {
        this._finderOptions.joins = joins;
        return this;
      }
    },

    include: function (include) {
      if(include == undefined) {
        return this._finderOptions.include
      } else {
        this._finderOptions.include = include;
        return this;
      }
    },

    order: function (order) {
      if(order == undefined) {
        return this._finderOptions.order
      } else {
        this._finderOptions.order = order;
        return this;
      }
    },

    offset: function (offset) {
      //this.setState('needsReload');
      //this.resetData();
      if(offset == undefined) {
        return this._finderOptions.offset  || (this._data && this._data.offset) || 0
      } else {
        this._finderOptions.offset = offset
        return this;
      }
    },

    limit: function (limit) {
      if(limit == undefined) {
        return this._finderOptions.limit || (this._data && this._data.limit)
      } else {
        this._finderOptions.limit = limit;
        return this;
      }
    },

    reload: function () {
      this.load()
    },

    load: function (options) {
      options = options || {};
      var me = this;
      me.setState('loading');
      if (this.handlers().allExpired()) {
        this.handlers().enableAll()
      }
      this._load({
        parameters: this._finderOptions.toQueryParams(),
        onSuccess: function (transport) {
          var response = transport.responseJSON;
          if (response) {
            me._data = response
            me.setState('loaded')
          }
          if (options.onSuccess) {
            options.onSuccess()
          }
        },
        onFailure: function () {
          me.context().notifier().error('Failed to load data for ' + me.type().meta.className())
        }
      })
      return this // allow method chaining since return value not needed
    },

    _load: function (options) {
      var path
      if(this.type().collectionRoute && this.type().collectionRoute()) {
        path = this.type().collectionRoute().getInterpolatedPath(Object.extend(params, this.context().path().vars()))
      } else {
        path = this.context().routes().pathFor(this.type(), 'index', this.context().path().vars())
      }

      new Ajax.Request(path, {
        parameters: options.parameters,
        method: 'get',
        requestHeaders: {
          Accept: 'application/json'
        },
        onSuccess: options.onSuccess,
        onFailure: options.onFailure
      });
    },

    inject: function (accInit, func, context) {
      return this.entries().collect(function (object) {
        return Object.values(object).first()
      }).inject(accInit, func, context);
    },

    onChange: function () {
      this.changed();
      this.notifyObservers()
    }
  }
})
