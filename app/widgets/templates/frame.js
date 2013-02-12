//= require <widget>
//= require <queue>
//= require <state>
//= require <roles/fires_events>
//= require <int_event_handler_set>

/** section: Widget
 *  class Frame
 *
 *  Widget object representing a frame and contents attached to a tab that
 *  resides at a current uri location.  This is equivalent to the tab
 *  container in a standard browser.  `Frames` have unique ids based on page
 *  numbers assigned by the `FrameStack`.  `Frames` are also linked to the
 *  current uri location through `PageLoader` objects.
 *
**/
Module('Templates', function() {
  JooseClass('Frame', {
    isa:  Widget,
    does: Stateful,
    has: {
      context:         { is: 'rw' },
      route:           { is: 'ro' },
      page:            { is: 'ro' },
      outerQueue:      { },
      backButtonActive: { is: 'ro', init: false },
      history:         { is: 'ro', init: function () { return []; } },
      handlers:   { is: 'ro', init: function () { return $Handlers([], this) } },
      states:  { is: 'ro', init: function () { return $States([
        [ 'nothingRendered', 'loadRendered', 'pageRendered'],
        [ 'notDisplayed', 'displaying', 'displayed' ] // for triggers previously handled by postRender, now handled by 'displayed' state
      ], this)}},
      queue:           { }
    },
    after: {
      initialize: function () {
        this.state().set('nothingRendered');
        this.state().set($(this.id()) ? 'displayed' : 'notDisplayed');
        this.handlers().push(
          this.iMode().on('change', function () {
            if(this.page() && this.page().htmlLoader && this.page().htmlLoader()) { // if htmlLoader need to reload before final rerender and display
              this.page().htmlLoader().load({ iMode: this.iMode().get() })
//              this.page().on('state:loaded', function () {
//                if(this.render()) { this.refresh() }
//              }, { once: true }, this)
            } else {
              if (
                (!this.page() || this.page().canRender()) && this.render()
              ) {
                this.refresh()
              }
            }

          }, this)
        )
       // if(this.route()) { this.getPage(this.route()) } } },
      }
    },
    methods: {
      state: function () {
        return this.states()
      },

      back: function () {
        this.unloadPage({ history: false });
        if(!this._history.empty()) {
          this._page = this._history.pop();
          this.fire('historyUpdate');
          this._loadPage()
        } else {
          this.close();
        }
      },

      reloadPage: function () {
        var page = this._page;
        this.unloadPage({ history: false });
        this._page = page;
        this._loadPage()
      },

//      handleEvent: function (event) {
//        switch(event.type()) {
//          case 'loaded':
//
//        }
//      },
      notifier: function () {
        return this.context().notifier(); },

      templates: function () {
        return this.context().templates() },

      unloadPage: function (options) {
        options || (options = {});
//        this.handlers().expireAll();
//        this._handlers = $Handlers([], this);
        this._page.unload();
        if(options.history !== false) {
          this._history.push(this._page)
          this.fire('historyUpdate');
        }
        delete this._page;
        delete this._rendered;
        this.setState('notDisplayed') // set this so that after display handlers do not fire prematurely as new page is loaded
      },

//      pathOrPathnameToRoute: function (pathOrPathname) {
//        pathOrPathname = pathOrPathname.sub(/\/$/, ''); // get rid of trailing slash
//        var route
//        if(pathOrPathname.blank() || pathOrPathname.match(/\//)) {
//          pathOrPathname = params['path_prefix'] ? pathOrPathname.sub(params['path_prefix'], '') : pathOrPathname; // handle path prefixed paths as regular paths
//          route = Route.forPath(pathOrPathname)
//  //        return this._pageForPath(pathOrPathname)
//        } else {
//          route = Route.forPathname(pathOrPathname)
//  //        return this._pageForPathname(pathOrPathname)
//        }
//        return route
//      },

      /**
       *  Frame#go(pageName) -> undefined
       *  - pageName (String): The name of the page to visit and load.
      **/
      loadPage: function(pathOrPathname, options) {
        options = options || {};
        var me = this;

        var renderOptions = Object.clone(options);
        delete options.render;

        me._loadQueue = (me._loadQueue && me._loadQueue.clear()) || new Queue(); // if frame already set up to load previous page, stop trying to load that page and load new page
        
        if(this._page) {
          this.unloadPage();
        }
        var newContext = this.context().clone({ frame: this }); // construct a new context for all elements within new page
        Object.extend(newContext.params(), options);

        //var route = this.pathOrPathnameToRoute(pathOrPathname)
        //this._page = new (this.context().routes().pageFor(route, options))({ frame: this, context: newContext, route: route })
        this._page = new (this.context().routes().pageFor(pathOrPathname, options))({ frame: this, context: newContext})//, route: route })
		Object.extend(params, options) // if new page loaded, parameters for fetching page should become part of params object
        if(renderOptions.render !== false) {
          this._page.handlers().push(
            this._page.on('state:loading', function () { if(this.render()) { this.refresh() } }, this),
            this._page.on('state:loaded', function (event, prevState) { if (prevState == 'loading' || this._page.initRender() !== false) { if(this.render()) { this.refresh() } } }, this)
          )
        }
        this._loadPage(renderOptions);        
      },

      _loadPage: function (options) {
        options || (options = {})
        var shouldRender = options.render === false ? false : true;
        var shouldInitRecords = shouldRender && (!this.page().htmlLoader || !this.page().htmlLoader())  // don't fetch initial data for records if not rendering, or if render is coming from server-side

        this._page.load({ onto: this, queue: this._loadQueue, shouldInitRecords: shouldInitRecords, initRender: options.initRender }); // hold off on loading records if records are not needed immediately for render - don't want to trigger view changes unnecessarily
//        if(shouldRender) {
//          if(this.render()) { me.display() }
//        }
      },

      onChange: function (event) {
        if(this.page() && this.page().onChange) { this.page().onChange(event) } }, // needed for taxon details page right now

      onSubmit: function (event) {
        if(this.page() && this.page().onSubmit) { this.page().onSubmit(event) } },

      onClick: function (event) {
        if(this.page() && this.page().onClick) { this.page().onClick(event) } },

      onMouseover: function (event) {
        if(this.page() && this.page().onMouseover) { this.page().onMouseover(event) } },

      onMouseout: function (event) {
        if(this.page() && this.page().onMouseout) { this.page().onMouseout(event) } },

      render: function () { },
      show: function () { },
      close: function () { },

      display: function () {
        this.setState('displaying');
        this.is('pageRendered') ?
          this._displayRender()
        : this.is('loadRendered') ?
          this._displayLoading()
        : throwError('Could not display: render has not been performed yet.');
      },
      refresh: function () { this.display(); },

      _displayRender:  function () {
        this._display(this._rendered);
        this.setState('displayed');
//        this.widgets().each(function(widget) {
//          widget[1].state().set('rendered');
//        }, this);
        if(this.page && this.page() && this.page().postRender) { this.page().postRender() }
      },
      _displayLoading: function () { this._display(this._rendered); },
      _display:        function () { } // must be defined in subclass
    }
  })
});
