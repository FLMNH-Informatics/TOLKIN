//= require <roles/context>
//= require <path>
//= require <interact_mode>
//= require <config/routes>
//= require <router>
////= require <uid_provider>
//= require <template_loader>
//= require <roles/fires_events>
//= require <asset_tag_helper>

JooseClass('Context', {
  does: [ TOLJS.role.Context, Roles.FiresEvents, AssetTagHelper ],
  has: {
    interactMode:     { is: 'rw', init: function () { return new TOLKIN.InteractMode({ context: this }) }},
    globalCart:       { is: 'rw' },
    currentSelection: { is: 'ro', init: function () { return new TOLKIN.CurrentSelection({ context: this}); }},
    viewport:         { is: 'rw' },
    notifier:         { is: 'rw' },
    mouseTooltip:     { is: 'rw' },
    templates:        { is: 'ro', init: function () { return new TOLKIN.TemplateLoader() }},
    routes:           { is: 'ro', init: function () { return new Router() }},//{ context: this }) } },
//    uids:             { is: 'ro', init: function () { return new UidProvider() } },
    path:             { is: 'ro', init: function () { return new TOLJS.Path(location.pathname) } },
    params:           { is: 'ro', init: function () { return Object.clone(params) } },
    frame:            { is: 'ro' }
  },
  methods: {
    clone: function (options) {
      var context = new Context({
        interactMode:     this._interactMode,
        globalCart:       this._globalCart,
        currentSelection: this._currentSelection,
        viewport:         this._viewport,
        notifier:         this._notifier,
        mouseTooltip:     this._mouseTooltip,
        templates:        this._templates,
        routes:           this._routes,
//        uids:             this._uids,
        path:             this._path,
        params:           Object.clone(this._params),
        frame:            options.frame
      });
      return context;
    },
    designatedFrame: function () { return this.viewport().designatedFrame(); }
  }
});
