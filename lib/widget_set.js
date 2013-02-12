//= require <registry>

JooseClass('WidgetSet', {
  isa: Registry,
  has: {
    loaded: { is: 'ro', init: false }
  },
  methods: {
    load: function () {
      var me = this;
      this.each(function(pair) { // if any widgets not owned by given owner, register those widgets to true parents
        if(pair.value.parent != me.owner()) {
          var singleHash = $H();
          singleHash.set(pair.key, pair.value);
          pair.value.parent().addWidget(singleHash); // pass along widget to appropriate parent in a hash of $H({ nickname: widget })
        }
      })
      this._loaded = true;
      this.fire('widgets:loaded');
    }
  }
})

$WSet = function (hash, owner) {
  return new WidgetSet({ initial: hash, owner: owner})
}
$Widgets = $WSet;