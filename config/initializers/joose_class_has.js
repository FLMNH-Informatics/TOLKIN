JooseClass('Joose.ClassAttribute', {
  isa: Joose.Attribute,
  methods: {
    apply: function (classObject) {
      var meta  = classObject.meta;
      var name  = this.getName();

      this.handleProps(classObject)

      meta.classAttributeNames = meta.classAttributeNames || []
      meta.classAttributeNames.push(name)

      meta.classAttributes = meta.classAttributes || {}
      meta.classAttributes[name] = this;
    },

    handleInit: function (classObject) {
        var props       = this.getProps();
        var name        = this.getName();
        var storeAsName = this.getStoreAsName();

        classObject[storeAsName]     = null; // CHANGED
        if(typeof props.init != "undefined") {
            var val = props.init;
            var type = typeof val;

            classObject[storeAsName] = val; // CHANGED
            this.doInitialization(classObject);
        }
    },

    doInitialization: function (object) {
        var   name  = this.initializerName();
        var  _name  = this.getName();
        var __name  = this.getStoreAsName();
        var value;
        var isSet  = false;
        var props = this.getProps();

        var init  = props.init;

        if(typeof init == "function") {
            // if init is not a function, we have put it in the prototype, so it is already here
            value = init.call(object)
            isSet = true
        }
        if(isSet) {
            var setterName = this.setterName();
            if(object.meta.can(setterName)) { // use setter if available
                object[setterName](value)
            } else { // direct attribute access
                object[__name] = value
            }
        }
    },

    addGetter: function (classObject) {
        var meta        = classObject.meta;
        var name        = this.getName();
        var storeAsName = this.getStoreAsName();
        var props       = this.getProps()

        var getterName = this.getterName();

        if(classObject[getterName]) { // never override a method - CHANGED
            return
        }

        var func  = function getter () {
            return this[storeAsName]
        }

        var init  = props.init;

        if(props.lazy) {
            func = function lazyGetter () {
                var val = this[storeAsName];
                if(typeof val == "function" && val === init) {
                    this[storeAsName] = val.apply(this)
                }
                return this[storeAsName]
            }
        }

        classObject[getterName] = func; // CHANGED
    },

    addSetter: function (classObject) {
        var meta        = classObject.meta;
        var name        = this.getName();
        var storeAsName = this.getStoreAsName();
        var props       = this.getProps();

        var setterName = this.setterName();

        if(classObject[setterName]) { // do not override methods - CHANGED
            return
        }

        var isa   = this.getIsa();

        var func;
        if(isa) {

            var checkerFunc = Joose.TypeChecker.makeTypeChecker(isa, props, "attribute", name)

            // This setter is used if the attribute is constrained with an isa property in the attribute initializer
            func = function setterWithIsaCheck (value, errorHandler) {
                value = checkerFunc(value, errorHandler)
                this[storeAsName] = value
                return this;
            }
        } else {
            func = function setter (value) {
                this[storeAsName] = value
                return this;
            }
        }
        classObject[setterName] = func; // CHANGED
    }
  }
});
Joose.Class.prototype.addSuperClass = function (classObject) {
  this.dieIfString(classObject);
  var me    = this;

  //this._fixMetaclassIncompatability(classObject)

  // Methods
  var names = classObject.meta.getMethodNames();
  for(var i = 0, len = names.length; i < len; ++i) {
      var name = names[i]

      var m = classObject.meta.getMethodObject(name)
      if(m) {
          var method = m.copy();
          method.setIsFromSuperClass(true);
          me.addMethodObject(method)
      }
      // there can be class methods and instance methods of the same name
      m = classObject.meta.getClassMethodObject(name)
      if(m) {
          var method = m.copy();
          method.setIsFromSuperClass(true);
          me.addMethodObject(method)
      }
  }

  // Attributes
  Joose.O.eachSafe(classObject.meta.attributes, function (attr, name) {
      me.addAttribute(name, attr.getProps())
  })

  // Class Attributes - ADDED
  Joose.O.eachSafe(classObject.meta.classAttributes, function (attr, name) {
      me.addAttribute(name, attr.getProps())
  })

  // Roles
  var roles = classObject.meta.roles
  for(var i = 0, len = roles.length; i < len; ++i) {
      var role = roles[i]
      me.roles.push(role)
  }

  this.parentClasses.unshift(classObject)
};

Joose.Class.meta.addMethod('handlePropclassHas', function (map) {
  var me = this;
  Joose.O.eachSafe(map, function (props, name) {
    me.addAttribute(name, Object.extend(props, { metaclass: Joose.ClassAttribute }));
    //me.addAttribute(name, props);
  })
});