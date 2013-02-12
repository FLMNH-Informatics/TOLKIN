//= require <templates/frame>
//= require "interact_mode_switch"

Module('General', function () {
  JooseClass('ContentFrame', {
    isa: Templates.Frame,
    has: {
      context: { is: 'ro', required: true, nullable: false },
//      pageFactory: { is: 'ro', init: function () { return new TOLKIN.PageFactory({frame:this}) }},
      widgets: { is: 'ro', init: function () { return $Reg({
            interactModeSwitch: new General.InteractModeSwitch({parent: this, context: this.context() })
      }, this)}}
    },
    methods: {
      render: function (args) {
        var content;
        var pageLoaded = !this.page || !this.page() || this.page().state().is('loaded') ? true : false;
        if(!pageLoaded) {
          content = 'loading ...';
        } else if(this.page && this.page()) {
          content = this.page().renderToString ? this.page().renderToString() : this.page().render();
        } else {
          content = args.yield;
        }
        this._rendered = content;
        this.state().set(pageLoaded? 'pageRendered' : 'loadRendered');
        return this._rendered;
      },
      
      _display: function (toDisplay) { $('viewport').down('.elastic_contents').update(toDisplay); }
    }
  })
});
