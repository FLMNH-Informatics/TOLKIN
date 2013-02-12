//= require <roles/stateful>

/** section: Library
 *  class Templates
 *
 *  A global object that handles loading, storing, and distributing `Templates`
 *  (including partials) originating from the server.  The `Template` class being
 *  used is from the Prototype Framework.  Please see Prototype documentation
 *  for more information on the `Template` class.
 *
 *  `Templates` must be `loaded` first before they can be retrieved by other
 *  javascript objects.
 *
 **/
Module('TOLKIN', function() {
  JooseClass('TemplateLoader', {
    does: Stateful,
    has: {
      //loaded: { is: 'ro' },
      syntax: {
        init: function() {
          return /(^|.|\r|\n)(\<%=\s*([^%]+?)\s*%\>)/
        }
      },
      storedTemplates: {
        init: { },
        nullable: false
      },
      // FIXME: loadStateSemaphore setup is not ideal - 'loaded' state will not be triggered for anyone until all have loaded
      // ideally request should be sent from the template set and state handled there and templates merely copied to what is
      // now called the 'TemplateLoader'
      loadStateSemaphore: { init: 0 }, // multiple loads could be taking place at same time - only change state appropriately when all have completed loading
      states: { is: 'ro', init: function () { return $States([
       [ 'notLoaded', 'loading', 'loaded']
      ], this) } }
    },
    after: {
      initialize: function () {
        this.setState('notLoaded');
      }
    },
    methods: {
      state: function () { return this.states() },
      /**
     *  Templates.load(templateAddresses) -> undefined
     *  - templateAddresses (String | Array) - Either one address or an array of
     *  addresses for the templates to be loaded.
     *
     *  Retrieves templates from server and stores them in local memory as
     *  `Templates` until requested.
     **/
      load: function(templateAddresses, options) {
        options || (options = {});
        this.setState('loading')
        this._loadStateSemaphore++;
        var me = this;
        //this._loaded = false; // signal that loading has started - THIS WILL NOT WORK IF THERE ARE OVERLAPPING TEMPLATE REQUESTS
        var rand;
        if(!Object.isArray(templateAddresses)) {
          templateAddresses = [ templateAddresses ];
        }
        var handler = this;
        var notFound = templateAddresses.select(function(templateAddress) {
          return !this._storedTemplates[templateAddress]
        }, this)
        var templatesCompact = notFound.join(',')
        if(templatesCompact != '') {
          rand = Math.random();
          new Ajax.Request('/templates/' + templatesCompact, {
            method: 'get',
            requestHeaders: {'Accept' : 'application/json'},
            onSuccess: function(transport) {
              if(!transport.responseText.blank()) {
                //me._loaded = true; // signal templates have loaded
                notFound.each(function(templateName) {
                  handler._storedTemplates[templateName] = transport.responseText.evalJSON()[templateName]
                });
                me._loadStateSemaphore--;
                if(me._loadStateSemaphore == 0) { me.setState('loaded'); }
                if(options.onSuccess) {options.onSuccess()}
              }
            }
          });
        } else {
          //this._loaded = true; // signal templates are loaded
          this.setState('loaded');
          rand = undefined;
          if(options.onSuccess) {options.onSuccess()}
        }
        return rand;
      },

      /**
     *  Templates.get(templateAddress) -> Template
     *  - address (String) - Address for the template to be retrieved.
     *  - klass (Object) - Class of template to retrieve. Optional.
     *
     *  Retrieves a `Template` with the given address from local memory.  `Templates`
     *  must be preloaded with the `load` method.
     **/
      get: function(address, klass) {
        klass = klass || Template;
        if(!this._storedTemplates[address]) {
          return null;
          //throw new TOLJS.Exception("template '" + address + "' not found locally")
        }
        return new klass(this._storedTemplates[address], this._syntax);
      }
    }
  })
});
