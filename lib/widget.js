//= require <roles/parent_dependent>
//= require <roles/registers_widgets>
//= require <roles/event_delegator>
//= require <int_event_handler_set>

/** section: Widget
 *  class Widget
 **/
JooseClass("Widget", {
  isAbstract: true,
  does: [ Roles.EventDelegator, TOLJS.role.RegistersWidgets ],
  has: {
    parent: { is: 'ro', required: true, nullable: false },
    context: { },
    //    context: { is: 'ro', init: null },

    id: { is: 'ro', lazy: true, init: function () { return [
          this.parentId(),
          this.meta.className().
            sub(/^((Widgets\.)|(Templates\.)|(General\.))/, '').
            gsub(/\./, '').underscore()
    ].join('_') } },
    handlers: { is: 'ro', init: function () { return $Handlers([], this) }
    }//,
    //    uid: {
    //      is: 'ro',
    //      init: function () {
    //        return this.context().uids().get()
    //      }
    //    }
  },
  // can't do this after initialize - parent widgets registry very possibly not loaded yet
  // and so cannot be accessed
  //    after: {
  //      initialize: function () {
  //        if(this.parent() && this.parent().widgets().get(this.id()) != this) {
  //          this.parent().widgets().add(this);
  //        }
  //      }
  //    },
  methods: {
    element: function () {
      return $(this.id())
    },

    frame: function () {
      return (this.parent().meta.isa(Templates.Frame) ? this.parent() : this.parent().frame())
    },

    onDisplay: function () {
      this.widgets && this.widgets().each(function (pair) {
          pair.value.onDisplay && pair.value.onDisplay();
        });
    },

    params: function () {
      return this.context().params();
    },

    context: function () { // was failing in some circumstances up in attrs
      return (
        this._context ||
        ( this._context =
            ((it = this.frame()) && (it = it.page()) && (it.context())) ||
          this.parent().context()
        )
      )
    },

    //    context: function () {
    //      return(this._context || (this._context = this.parent().context()))
    //    },

    designatedFrame: function () {
      return this.viewport().designatedFrame();
    },

    unload: function() {
      this.handlers && this.handlers().expireAll();
      this.widgets && this.widgets().each(function (pair) {
          pair.value.unload();
        });
      //this.parent().widgets().remove(this);
    },

    refresh: function () {
      if($(this.id())) {
        $(this.id()).replace(this.render())
      }
    },

    render: function() {
      return this.renderToString();
    },

    parentId: function() {
      return this.parent().id();
    },

    iMode: function () {
      return this.interactMode()
    },
    interactMode: function () {
      return this.context().interactMode();
    },

    templates: function () {
      return this.context().templates();
    },

    currentSelection: function () {
      return this.parent().currentSelection();
    },

    globalCart: function () {
      return this.parent().globalCart();
    },

    notifier: function () {
      return this.parent().notifier();
    },

    widget: function (name) {
      return this.widgets().get(name);
    },

    template: function (name) {
      return this.templates().get(name);
    },

    route: function (path_name, options) {
      return this.context().routes().pathFor(path_name, Object.extend(Object.clone(this.params()),options))
    },

    routes: function () {
      return this.context().routes()
    },

    top: function () {
      return this.viewport();
    },

    viewport: function () {
      return(this.context().viewport() ||
        this.parent ?
        this.parent().viewport ?
        this.parent().viewport()
        : this.parent()
        : this
      )
    }
  }
})
