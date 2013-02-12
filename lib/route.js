Route = function (routeHash) {
  Object.extend(this, routeHash);
}
Object.extend(Route, {
  forPathname: function (pathname) {
    return new Route(Routes.PATHNAMES_TO_ROUTES[pathname.sub(/_path/, '')])
  },

  forPath: function (path) {
    var nippedPath = path.sub(/^\//, '');
    var splitPath =
      nippedPath.blank() ?
        [] :
        nippedPath.split('/');
    var routeHash =
      splitPath.
        inject(Routes.PATHS_TO_ROUTES, function (acc, part, i) {
          return (
            part.match(/^[\d,-]+$/) ?
//              i == (splitPath.size() - 1)? // is last in array
              Object.extend(Object.clone(acc[':id']||{}), acc[':'+splitPath[i-1].singularize()+'_id']) :
//                acc[':id'] :
//                acc[':'+splitPath[i-1].singularize()+'_id'] :
              acc[part]
          )
        });
    return new Route(Object.extend(routeHash, {path: path}));
  },

  forModelAction: function (model, action) {
    return this.forControllerAction(model.toString().underscore().pluralize(), action)
  },

  forControllerAction: function (controller, action) {
    //TODO: Hack to fix incorrect pluralization.  Something is wrong with the syncrecord
    if (controller == "molecular/matrices/cells"){
      controller = "molecular/matrix/cells";
    }
    return new Route(Routes.CONTROLLERS_ACTIONS_TO_ROUTES[controller][action])
  }

});
Route.prototype = {
  getParentRoute: function () {
    var splitPath = this.path.split('/');
    splitPath.pop();
    if(splitPath.size() == 1) {splitPath.push('')} // this is used to return '/' when at home path
    return Route.forPath(splitPath.join('/'));
  },

  getPath: function () {
    return this.path
  },

  buildPath: function (addVars) {
    var path = this.path.gsub(
      /\(?(\.)?:(\w+)\)?/,
      function (match) {
        return (
          addVars[match[2]] ?
             (match[1]||'')+addVars[match[2]] :
             ''
        )
      }
    )
    return addVars['extraParams'] ? path + addVars['extraParams'] : path;
  },

  buildInterpolatedPath: function (addVars) {
    return this.buildPath(addVars)
  },

  getInterpolatedPath: function (addVars) {
    return this.buildInterpolatedPath(addVars)
  }
}
