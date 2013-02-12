//= require <widgets/templates/frame>
//= require <general/user_notification_toast>
//= require <general/content_frame>
//= require <general/mouse_tooltip>
//= require <widgets/templates/window>
//= require <config/routes>
//= require <template_loader>
//= require <event_router>
//= require <session>

JooseClass('Viewport', {
  isa: Templates.Frame,
  has: {
      id:           { is: 'ro', init: 'viewport' },
      context:      { is: 'ro', required: true, nullable: false },
      eventRouter:  { is: 'ro', lazy: true, init: function () { return new TOLKIN.EventRouter({viewport:this}) }},
      //pageFactory:  { is: 'ro', init: function () { return new TOLKIN.PageFactory({frame:this}) }},
      parent:       { is: 'ro', init: null },
      widgets:      { is: 'ro', init: function () { return $Reg({
                      mouseTooltip: new General.MouseTooltip({ parent: this }),
                      notifier:     new General.UserNotificationToast({ parent: this }),
                      contentFrame: new General.ContentFrame({ parent: this, context: this.context() }),
                      window:       new Templates.Window({parent: this, context: this.context() })
                    }, this ) } },
      designatedFrame: { is: 'rw' }
  },
  after: {
    initialize: function () {
      this.setDesignatedFrame(this.widgets().get('contentFrame'));
      this.context().setViewport(this);
    }
  },
  methods: {
    load: function () {
      this.context().setNotifier(this.widgets().get('notifier'));
      this.context().setMouseTooltip(this.widgets().get('mouseTooltip'));
      new TOLKIN.Session({context: this.context()}).load();
      this.widgets().get('contentFrame').loadPage(window.location.pathname, { initRender: false })//, { render: false });
      this.eventRouter(); // wait to load eventRouter until the end so events can be passed to correct widgets
    },
//      start: function () {
////        this.widgets().add(
////          new TOLKIN.views._UserNotificationToast({ parent: this })
////        );
////        this.widgets().add(
////          new TOLKIN.views._ContentFrame({ parent: this, context: this.context() }).go(params['controller'] + '/' + params['action'], { render: false })
////        );
//      },
//    notifier: function () {
//        return this.widgets().get('notifier');
//    },

    currentSelection: function () {
      return this.context().currentSelection();
    },

    globalCart: function () {
      return this.context().globalCart();
    },

    interactMode: function(){
       return this.context().interactMode();
    },

    templates: function () {
      return this.context().templates();
    },

    designatedFrame: function () { return this._designatedFrame; },
      viewport: function () { return this; }
  }
});


