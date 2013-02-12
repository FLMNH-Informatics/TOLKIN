//= require <joose>
//= require <windows_js/init>
//= require "initializers/prototype_ajax_request"
//= require "initializers/joose_class_default_initializer"
//= require "initializers/joose_handle_lazy_overridden_attrib"
//= require "initializers/joose_attribute"
//= require "initializers/joose_class_has"
//= require "initializers/templates"
//= require "initializers/inflections"
//= require "initializers/window"
//= require "initializers/open_in_new_tab"
//= require "initializers/string_eval_json"
//= require "initializers/array_index"
//= require "initializers/array_empty"
//= require "initializers/windows_js_to_front"
//= require "initializers/joose_inherits_from_on_meta"
//= require "initializers/element_fire"
//= require "initializers/iframe_dom_traversal"
//= require "initializers/object_value"
//= require "initializers/element_upper"
//= require "initializers/string_inflectors"
//= require <context>
//= require <viewport>

// camelize incoming params
(function () {
  for(var k in params) {
    params[k.camelize()] = params[k];
  }
})();

JooseClass('Init', {
  has: {
    viewport: { is: 'ro', init: function () { return new Viewport({ context: new Context() }) }}
  },
  methods: {
    start: function() {
      this.viewport().load(); // load main page
    }
  }
});

var root = this;
var top  = this;
var init = new Init();
try {
  init.start()
} catch(error) {
  // may need to create new notifier to handle error message if notifier not created yet
  init.viewport().widgets().get('notifier').error(error);
  throw error;
}
