//= require <record_set>
//= require <widget_set>
//= require <template_set>
//= require <html_loader>
//= require <roles/stateful>
//= require <shift_checking>

JooseClass('Page', {
  does: [Stateful, ShiftChecking],
  has: {
// NOTE: the below attrs are commented out because joose error will be raised if attrs are overridden by child class with lazy option used
//    records:   { is: 'rw', init: function () { return $Records({}, this) }},
//    widgets:   { is: 'rw', init: function () { return $Widgets({}, this) }},
//    templates: { is: 'rw', init: function () { return $Templates([], this) }},
//    htmlLoader { is: 'rw', init: function () { return $HtmlLoader(function () { }, this) } }
    frame: { is: 'ro', required: true, nullable: false },
    states: { is: 'ro', init: function () { return $States([
      [ 'unloaded', 'initLoading', 'loading', 'loaded']
    ], this) } },
    canRender:     { is: 'ro', required: true, nullable: false },
    savable:       { is: 'ro', init: false },
    saveButtonText:{ is: 'ro', init: 'Save' },
    rendered:      { is: 'ro' },
    context:       { is: 'ro', init: function () { return this.frame().context() } },
    width:         { is: 'ro', init: null },
    height:        { is: 'ro', init: null },
    loadingCount:  { init: 3 },
    handlers:      { is: 'ro', init: function () { return $Handlers([], this) } },
    initRender:    { is: 'ro' },
//    lastClicked:   { is: 'rw', lazy: true }
    //route:         { is: 'ro', required: true, nullable: false }
  },
  after: {
    initialize: function () {
      this.handlers().push(
        this.frame().on('state:displayed', this.onDisplay.bind(this))
      )
      if (this.records) {
        this.handlers().push(
          this.records().on('state:loaded', this.handleLoadedEvent.bind(this)), // ChrisG - 2011.03.31 - took out once: true so that reloading records will trigger page loading again, necessary to avoid impossible render situations
          this.records().on('state:loading', function () { if (this.not('unloaded')) { this.setState('loading') } }, this) // FIXME - not foolproof - will not catch second loading event that may happen during first
        )
      }
      if (this.htmlLoader) {
        this.handlers().push(
          this.htmlLoader().on('state:loaded', this.handleLoadedEvent, this),
          this.htmlLoader().on('state:loading', function () { if (this.not('unloaded')) { this.setState('loading') } }, this)
        )
      }
      this.setState('unloaded')
    }
  },
  methods: {
    _parentPage: function(){ return this._frame._parent._designatedFrame._page; },
    state: function () { return this.states() },
    designatedFrame: function () { return this.frame().designatedFrame(); },
    iMode: function () { return this.interactMode() },
    interactMode: function () { return this.frame().interactMode(); },
    onDisplay: function () {
      this.widgets && this.widgets().each(function (pair) {
        pair.value.onDisplay && pair.value.onDisplay();
      });
    },

    notifier: function ()     { return this.context().notifier() },
    params:   function ()     { return this.context().params(); },
    widget:   function (name) {
      return this.widgets().get(name);
    },
    record:   function (name) { return this.records().get(name); },
    route:    function (pathname) { return this.context().routes().pathFor(pathname, this.params()); },

//    pathFor: function (pathname, options) {
//      return (
//        Route.
//          forPathname(pathname).
//          buildPath(
//            Object.extend(this.params(), options)
//          )
//      )
//    },

    template: function (name) {
      return this.frame().templates().get(
        name ?
          name
          : this.meta.className().sub(/Views\./, '').underscore().gsub(/\./, '/')
      );
    },

    receiveMessage: function (message) {
      if(message.meta.className() == 'Messages.Loaded') {
        this._loadingCount--;
      }
    },

    handleLoadedEvent: function (event) {
      // just check that nothing is still in the process of loading - things have either been loaded or are in an unloaded state for a reason
      if (
        (!this.records || this.records().not('loading')) &&
        (!this.widgets  || this.widgets().loaded()) &&
        (!this.templates || this.templates().not('loading')) &&
        (!this.htmlLoader || this.htmlLoader().not('loading'))
      ) {
        this.onLoad();
      }
//      switch(event.type()) {
//        case 'loaded':
//          if((!this.records || this.records().state().is('loaded')) &&
//             (!this.widgets  || this.widgets().loaded()) &&
//             (!this.templates || this.templates().state().is('loaded'))) {
//             this.onLoad();
//           }
//           break;
//        case 'widgets:loaded':
//          if((!this.records || this.records().state().is('loaded')) &&
//             (!this.templates || this.templates().state().is('loaded'))) {
//             this.onLoad();
//           }
//           break;
//        case 'templates:loaded':
//          if((!this.records || this.records().state().is('loaded')) &&
//             (!this.widgets || this.widgets().loaded())) {
//             this.onLoad();
//           }
//           break;
//      }
    },

    render: function () {
      return this._rendered
    },

    unload: function () {
      this.handlers && this.handlers().expireAll();
      this.records && this.records().each(function(record) {
        record.unload();
      });
      this.widgets && this.widgets().each(function(pair) {
        pair.value.unload();
      });
      this.records && this.records().unloadAll()
      this.htmlLoader && this.htmlLoader().setState('unloaded')
      this.setState('unloaded');
    },

    load: function (options) {
      this._initRender = options.initRender
//      if(!options.onto) { throw("frame required") }
//      this.setFrame(options.onto)

      this.records &&
//        this.records().on('state:loaded', this.handleLoadedEvent.bind(this)) && // ChrisG - 2011.03.31 - took out once: true so that reloading records will trigger page loading again, necessary to avoid impossible render situations
//        this.records().on('state:loading', function () { if (!this.setState('loading')) { this.setState('loading') } }, this) &&
        options.shouldInitRecords && this.records().initRecords() // do this instead of load so that load is bypassed for records with initial data provided

      this.htmlLoader &&
//        this.htmlLoader().on('state:loaded', this.handleLoadedEvent, this) &&
//        this.htmlLoader().on('state:loading', function () { this.setState('loading') }, this) &&
        this.htmlLoader().load()

      this.widgets &&
        this.widgets().on('widgets:loaded', this.handleLoadedEvent.bind(this), { once: true }) &&
        this.widgets().load();

      this.templates &&
        this.templates().load({ onto: this.frame().templates() }) &&
        this.templates().on('state:loaded', this.handleLoadedEvent.bind(this), { once: true });

      this.handlers &&
        this.handlers() &&
        this.handlers().allDisabled() && // if handlers are disabled, reenable them (for page reloading)
        this.handlers().enableAll()
//      if(this.handlers().allDisabled()) { this.handlers().enableAll() }

      this.setState('initLoading') // keep unloaded state until after loading has been set in motion - listeners wfor records and htmlLoader checking for unloaded state

      if(!this.records && !this.widgets && !this.templates && !this.htmlLoader) {
        this.onLoad();
      }
    },
    onLoad: function () {
//      if(!this.records && !this.widgets && !this.templates) {
      this.setState('loaded')
//      }
    }
  }
//  after: {
//    initialize: function () {
//      this.frame().widgets().add(this.widgets())
//    }
//  }
});



