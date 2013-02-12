//= require <route>
//= require <general/blank_page>

JooseClass('Router', {
//  has: {
//    context:            { is: 'ro', required: true, nullable: false },
//    pathsByPathname:    { is: 'ro', init: function () { return {} }},
//    pathsByModelAction: { is: 'ro', init: function () { return {} }},
//    pagesByPath:        { is: 'ro', init: function () { return {} }},
//    pagesByPathname:    { is: 'ro', init: function () { return {} }}
//  },
//  after: {
//    initialize: function () {
////      this._build(this._routesConfig, [], [])
//    }
//  },
  methods: {
//    _actionFor: function (splitPath, resourcesArr) {
//      var pathContainer = this._pathContainerForResourcesArr(resourcesArr);
//      var action;
//      // determine action
//      if(splitPath.size() % 2 == 0) {
//        var actionOrId = splitPath.pop();
//        if(pathContainer[actionOrId]) {
//          action = actionOrId;
//        } else {
//          action = 'show';
//        }
//      } else {
//        if(splitPath.last() == resourcesArr.last()) {
//          action = 'index';
//        } else {
//          action = splitPath.last();
//        }
//      }
//      return action.camelize(true);
//    },
//
//    _pathContainerForResourcesArr: function (resourcesArr) {
//      //var splitModelName = [ this._pageKeyFor(resourcesArr), resourcesArr.last().camelize(true) ].flatten();
//      return(this._pageKeyFor(resourcesArr).inject(this.pathsByModelAction(), function (index, pathSnippet) {
//        return index[pathSnippet.camelize(true)]
//      }))
//    },

//    _pageKeyFor: function(resourcesArr) {
//      return resourcesArr.inject(this.pagesByPath(), function (index, pathSnippet) {
//        return index[pathSnippet];
//      });
//    },

//    _namespaceForResourcesArr: function (resourcesArr) {
//      return this._namespaceForNamespaceArr(this._pageKeyFor(resourcesArr))
////        this._pageKeyFor(resourcesArr).inject(Views, function (nameObj, keyItem) {
////          return nameObj[keyItem]
////        }
////      ));
//    },
//
//    _namespaceForNamespaceArr: function (namespaceArr) {
//      return(namespaceArr.inject && namespaceArr.inject(Views, function (nameObj, keyItem) {
//        return nameObj[keyItem]
//      }))
//    },

//    pageFor: function (route, options) {
//      var namespace = route.controller && route.controller.split('/').inject(root, function (root, part) {
//        return root[part.camelize(true)]
//      })
//      return ((namespace && namespace[route.action.camelize(true)+"Page"]) ||
//        (options.render === false ? General.BlankPage : General.GenericPage)
//      )
//    },
     pageFor: function (pathOrPathname) {
      pathOrPathname = pathOrPathname.sub(/\/$/, ''); // get rid of trailing slash
      var route
      if(pathOrPathname.blank() || pathOrPathname.match(/\//)) {
        pathOrPathname = params['path_prefix'] ? pathOrPathname.sub(params['path_prefix'], '') : pathOrPathname; // handle path prefixed paths as regular paths
        route = Route.forPath(pathOrPathname)
//        return this._pageForPath(pathOrPathname)
      } else {
        route = Route.forPathname(pathOrPathname)
//        return this._pageForPathname(pathOrPathname)
      }
      var namespace = route.controller.split('/').inject(root, function (root, part) {
        return root[part.camelize(true)]
      })

      if(!route.action){
          return Views.Layouts.Blank
      }else{
          return ((namespace && namespace[route.action.camelize(true)+"Page"]) || Views.Layouts.Blank)
      }
    },

//    _resourcesForResourcesActions: function (resourcesActions) {
//      var raWorking = resourcesActions.clone();
//      var verifiedResources = [];
//      var foundSoFar = this.pagesByPath();
//      do {
//        verifiedResources.push(raWorking.shift());
//        foundSoFar = foundSoFar[verifiedResources.last()]
//      } while(foundSoFar && raWorking.size() > 0)
//      if(!foundSoFar) { verifiedResources.pop() } // remove last name from names array if it couldn't be found in path index
//      return verifiedResources;
//    },

//    _pageForPath: function (path) {
//      var action, splitPath, namespace;
//      path = path.sub(/^\/$/, '/projects'); // handle blank path
//      splitPath = path.substr(1).split('/'); // leave off starting slash
//      splitPath = splitPath.reject(function (pathObj) { return pathObj.blank() });
//
//      var onlyResourcesActions = splitPath.reject(function(pathObj, index) { return(index % 2 == 1) });
//      var resourcesArr = this._resourcesForResourcesActions(onlyResourcesActions);
//
//      //var bareModelName = resourcesArr.last().camelize(true);
//
//      namespace = this._namespaceForResourcesArr(resourcesArr);
//      if (namespace) {
//        action = this._actionFor(splitPath, resourcesArr);
//        return this._pageForNamespaceAction(namespace, action);
//      } else {
//        return Views.Layouts.Blank;
//      }
////      var classShortName = onlyResourcesActions.last().camelize(true);
////      if (splitPath.size() % 2 == 0) {
////        return namespace[classShortName].Show;
////      } else {
////        return (namespace[classShortName] && namespace[classShortName].Index) || namespace.Layouts.Blank;
////      }
//    },


//    _actionFromPathname: function (namespace, pathname) {
//      var pathnameNoAction, splitName, isMemberAction, action, inflectionCheck;
//      pathnameNoAction = []; splitName = pathname.split('_');
//      pathnameNoAction.unshift(splitName.pop()); // remove '_path' ending
//
//      while(!splitName.empty()) {
//        pathnameNoAction.unshift(splitName.pop());
//        if(!inflectionCheck) {
//          inflectionCheck = pathnameNoAction.first(); // don't lose any parts of name
//          isMemberAction = (inflectionCheck.singularize() == inflectionCheck);
//        }
//        if(this.pathsByPathname()[pathnameNoAction.join('_')]) {
//          action = splitName.join('_').camelize(true);
//          if(namespace[action]) {  // NOTE: will fail if remaining namespace at this point forms valid action. i.e. new_project_collection_path and Collection namespace has both a 'New' and a 'NewProject' action
//            break;
//          }
//        }
//      }
//      if(!action) {
//        action = (isMemberAction) ? 'Show' : 'Index';
//      }
//      return action;
//    },

//    _pageForNamespaceAction: function (namespace, action) {
//      return((namespace && namespace[action]) || Views.Layouts.Blank)
//    },

//    _pageForPathname: function (pathname) {
//      var namespace, action;
//      namespace = this._namespaceForNamespaceArr(this.pagesByPathname()[pathname]);
//      action    = this._actionFromPathname(namespace, pathname);
//      return this._pageForNamespaceAction(namespace, action);
//    },

    path: function (pathname, addVars) {
      return this.pathsByPathname[pathname]
    },

//    _pathForPathname: function (pathname, addVars) {
//      var pathVars, path;
//      pathVars = $H(this.context().path().vars()).merge(params).merge(addVars).toObject();
//      path = this._pathsByPathname[pathname].interpolate({ p: pathVars })
//      path = path.gsub(/\/\//, '/'); // necessary to deal with namespaces in pathname
//      return([ params['path_prefix'], path].compact().join(''));
//    },

//    _pathForModelAction: function (model, action, addVars) {
//      addVars || (addVars = {});
//      var modelNameWithNamespace, shortName, insideObj, pathVars, path;
//      modelNameWithNamespace = model.meta.className().sub(/^Models\./, '').split('.');
//      shortName = modelNameWithNamespace.pop();
//      insideObj = modelNameWithNamespace.inject(this.pathsByModelAction(), function (obj, namePiece) {
//        return obj[namePiece.camelize(true)]
//      });
//      insideObj = insideObj[shortName.pluralize()];
//      pathVars = $H(this.context().path().vars()).merge(params).merge(addVars).toObject();
//      if(insideObj[action]) {
//        path = insideObj[action].interpolate({ p: pathVars })
//      } else {
//        path = insideObj['index'].interpolate({ p: pathVars })+'/'+action.underscore()
//      }
//      return([ params['path_prefix'], path].compact().join(''));
//    },

    // model here is model / model object class
    pathFor: function (modelOrPathname, actionOrAddVars, lastAddVars) {
      var route, addVars
      if(typeof modelOrPathname != 'string') {
        var controllerName = modelOrPathname.meta.getName().underscore().pluralize()

        route = Route.forControllerAction(controllerName, actionOrAddVars)
        addVars = lastAddVars
//        return this._pathForModelAction(modelOrPathname, actionOrAddVars, addVars);
      } else {
        route =  Route.forPathname(modelOrPathname)
        addVars = actionOrAddVars
//        return this._pathForPathname(modelOrPathname, actionOrAddVars);
      }
      return route.getInterpolatedPath(Object.extend(params, addVars))
    }//,

//    _build: function (obj, resourceArr, namespaceArr) {
//      this._parseNamespaces(obj, resourceArr, namespaceArr);
//      this._parseResources(obj, resourceArr, namespaceArr);
//    },
//    _parseNamespaces: function (obj, resourceArr, namespaceArr) {
//      if(obj.namespaces) {
//        for(var key in obj.namespaces) {
//          this._namespace(key, obj.namespaces[key], resourceArr, namespaceArr);
//          //var newNamespaceArr = namespaceArr.clone();
//          //this._build(obj.namespaces[key], resourceArr, newNamespaceArr.push(key) && newNamespaceArr)
//        }
//      }
//    },
//    _parseResources: function (obj, resourceArr, namespaceArr) {
//      if(obj.resources) {
//        for(var key in obj.resources) {
//          this._resource(key, obj.resources[key], resourceArr, namespaceArr)
//        }
//      }
//    },

//    _namespace: function (name, obj, resourceArr, namespaceArr) {
//      if(resourceArr.empty()) { // for starting namespaces add nodes for these to index
//        this._addPageKey(name, obj, resourceArr, namespaceArr)
//      }
//      var newNamespaceArr = namespaceArr.clone();
//      this._build(obj, resourceArr, newNamespaceArr.push(name) && newNamespaceArr)
//    },
//
//
//    _resource: function (name, obj, resourceArr, namespaceArr) {
//      this._addMemberActions(name, obj, resourceArr, namespaceArr);
//      this._addCollectionActions(name, obj, resourceArr, namespaceArr);
//      this._addMixedMemberCollectionActions(name, obj, resourceArr, namespaceArr);
//      this._addPageKey(name, obj, resourceArr, namespaceArr);
//
//
//      var newResourceArr = resourceArr.clone();
//      this._build(obj, newResourceArr.push(name) && newResourceArr, namespaceArr);
//    },

//    _addPageKey: function (name, obj, resourceArr, namespaceArr) {
//      var pagesIndex = namespaceArr.inject(this.pagesByPath(), function (index, namespace) { // follow starting namespaces to get correct inner index
//        return(index[namespace.underscore()] || index)
//      })
//      var addLoc = resourceArr.inject(pagesIndex, function (index, resource) {
//        return index[resource.underscore()];
//      })
//      var className = obj.className ? obj.className.pluralize() : name;
//      addLoc[name.underscore()] = [ namespaceArr, className ].flatten();
//    },
//
//    _addMixedMemberCollectionActions: function (name, obj, resourceArr, namespaceArr) {
//      var actions, path, pathname;
//      path = [ this._pathPrefix(resourceArr), name.underscore() ].join('/');
//      pathname = [ this._pathnamePrefix(resourceArr), name.underscore().singularize(), 'path'].compact().join('_');
//      actions = [ 'new' ];
//      this._addActions( name, obj, path, pathname, actions, namespaceArr )
//    },
//
//    _addMemberActions: function (name, obj, resourceArr, namespaceArr) {
//      var pathPrefix, pathnamePrefix, path, pathname, actions, defaultActions;
//
//      pathPrefix = this._pathPrefix(resourceArr);
//      pathnamePrefix = this._pathnamePrefix(resourceArr);
//      path = [ pathPrefix, name.underscore(), '#{p.id}' ].join('/');
//      pathname = [pathnamePrefix, name.underscore().singularize(), 'path'].compact().join('_');
//      defaultActions = [ 'show', 'update' ]
//      actions = [ defaultActions, obj['member']].compact().flatten();
//
//      this._addActions( name, obj, path, pathname, actions, namespaceArr )
//    },
//
//    _addActions: function (name, obj, path, pathname, actions, namespaceArr) {
//      actions.each(function(action) {
//        var actionPrefix;
//        switch(action) {
//          case 'show':   actionPrefix = null;   break;
//          case 'update': actionPrefix = null;   break;
//          case 'index':  actionPrefix = null;   break;
//          default:       actionPrefix = action; break;
//        }
//        var className = obj.className ? obj.className.pluralize() : name; // allow for different resource vs. class names
//        this.pathsByPathname()[[actionPrefix, pathname].compact().join('_')] = [ path, actionPrefix ].compact().join('/');
//        this.pagesByPathname()[[actionPrefix, pathname].compact().join('_')] = [ namespaceArr, className ].flatten();
//
//        var pathsByMAObj;
//        pathsByMAObj = namespaceArr.inject(this.pathsByModelAction(), function (obj, namespace) {
//          return(obj[namespace] || (obj[namespace] = {}))
//        });
//        if(!pathsByMAObj) { throw 'custom error' } // pathsByMAObj was evaling to undefined without this
//        if(!pathsByMAObj[className] || !pathsByMAObj[className][action] || obj['main'] == 'true' ) { // only set path if path already exists if path being set is main path
//        (pathsByMAObj[className] || (pathsByMAObj[className] = {}))[action] = [ path, actionPrefix ].compact().join('/'); // either set value on already existing hash or create new hash and add to it
//        }
//      }, this)
//    },
//
//    _addCollectionActions: function (name, obj, resourceArr, namespaceArr) {
//      var pathPrefix, pathnamePrefix, path, pathname, actions, defaultActions;
//      pathPrefix = this._pathPrefix(resourceArr);
//
//      pathnamePrefix = this._pathnamePrefix(resourceArr);
//      path = [ pathPrefix, name.underscore() ].join('/');
//      pathname = [pathnamePrefix, name.underscore(), 'path'].compact().join('_');
//      defaultActions = [ 'index' ]
//      actions = [ defaultActions, obj['collection']].compact().flatten();
//
//      this._addActions( name, obj, path, pathname, actions, namespaceArr )
//    },
//
//    _pathPrefix: function (resourceArr) {
//      var out = '/' +
//        resourceArr.map(function (resource) {
//          return ''+resource.underscore()+'/#{p.'+resource.underscore().singularize()+'_id}'
//        }).join('/');
//      if(out == '/') { out = '' }
//      return out;
//    },
//
//    _pathnamePrefix: function (resourceArr) {
//      var out = resourceArr.map(function (resource) { return resource.underscore().singularize() }).join('_');
//      if(out == '') { out = null }
//      return out;
//    }
  }
});
