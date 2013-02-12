

//// add stack traces to error messages generated
//Joose.Class.prototype._handlePropmethods = Joose.Class.prototype.handlePropmethods;
//Joose.Class.prototype.handlePropmethods = function(map) {
//  var me = this
//  Joose.O.eachSafe(map, function (func, name) {
//    var _func = func;
//    func = function() {
//      try {
//        return _func.apply(this, arguments);
//      } catch(error) {
//        if(Object.isString(error)) error = new TOLJS.Exception(error);
//        error.backtrace = (error.backtrace || "")+this.meta.className()+'#'+name+"()<br/>";
//        throw error;
//      }
//    }
//    me.addMethod(name, func)
//  })
//}


// TEMPLATE EXTENSIONS

// works like evaluate except doesn't replace matches it can't find data for
Template.prototype.softEval = function(object) {
  if (object && Object.isFunction(object.toTemplateReplacements))
    object = object.toTemplateReplacements();

  return this.template.gsub(this.pattern, function(match) {
    var orig = match[0];
    if (object == null) return orig;

    var before = match[1] || '';
    if (before == '\\') return orig;

    var ctx = object, expr = match[3];
    var pattern = /^([^.[]+|\[((?:.*?[^\\])?)\])(\.|\[|$)/;
    match = pattern.exec(expr);
    if (match == null) return orig;

    while (match != null) {
      var comp = match[1].startsWith('[') ? match[2].replace(/\\\\]/g, ']') : match[1];
      ctx = ctx[comp];
      if (null == ctx || '' == match[3]) break;
      expr = expr.substring('[' == match[3] ? match[1].length : match[0].length);
      match = pattern.exec(expr);
    }

    return (ctx ? before + String.interpret(ctx) : orig);
  });
}

// softEval but returns a Template object instead of a String object
Template.prototype.fill = function (object) {
  var evalResults = this.softEval(object);
  return new Template(evalResults, this.pattern);
}

Template.prototype.toString = function () {
  return this.template;
}