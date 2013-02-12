/*!
 * This is Joose
 * For documentation see http://code.google.com/p/joose-js/
 * Copyright (c) 2009 Malte Ubl
 * Generated: Tue Jan 12 13:53:55 2010
 */
// ##########################
// File: Joose.js
// ##########################
var joosetop = this;
(function () {
Joose = function () {
    this.cc              = null;  // the current class
    this.currentModule   = null
    this.top             = joosetop;
    this.globalObjects   = [];

    this.anonymouseClassCounter = 0;
};

// Static helpers for Arrays
Joose.A = {};
Joose.A.each = function (array, func) {
    for(var i = 0, len = array.length; i < len; ++i) {
        func(array[i], i)
    }
}
Joose.A.exists = function (array, value) {
    for(var i = 0, len = array.length; i < len; ++i) {
        if(array[i] == value) {
            return true
        }
    }
    return false
}
Joose.A.concat = function (source, array) {
    source.push.apply(source, array)
    return source
}

Joose.A.grep = function (array, func) {
    var a = [];
    Joose.A.each(array, function (t) {
        if(func(t)) {
            a.push(t)
        }
    })
    return a
}
Joose.A.remove = function (array, removeEle) {
    var a = [];
    Joose.A.each(array, function (t) {
        if(t !== removeEle) {
            a.push(t)
        }
    })
    return a
}

// Static helpers for Strings
Joose.S = {};
Joose.S.uppercaseFirst = function (string) {
    var first = string.substr(0,1);
    var rest  = string.substr(1,string.length-1);
    first = first.toUpperCase()
    return first + rest;
}

Joose.S.isString = function (thing) {
    if(typeof thing == "string") {
        return true
    }
    return false
}

// Static helpers for objects
Joose.O = {};
Joose.O.each = function (object, func) {
    for(var i in object) {
        func(object[i], i)
    }
}

Joose.O.eachSafe = function (object, func) {
    for(var i in object) {
        if(object.hasOwnProperty(i)) {
            func(object[i], i)
        }
    }
}

// Experimental!
Joose.O.extend = function (target, newObject) {
    for(var i in newObject) {
        var thing = newObject[i]
        target[i] = thing
    }
}


Joose.prototype = {

    addToString: function (object, func) {
        object.toString = func;
    },

    /*
     * Differentiates between instances and classes
     */
    isInstance: function(obj) {
        if(!obj.meta) {
            throw "isInstance only works with Joose objects and classes."
        }
        if(obj.constructor === obj.meta.c) {
            return true
        }
        return false
    },

    init: function () {
        this.builder = new Joose.Builder();
        this.builder.globalize()
    },
    // this needs to be updated in release.pl too, if files are added
    components: function () {
        return [
            "Joose.Builder",
            "Joose.Class",
            "Joose.Method",
            "Joose.ClassMethod",
            "Joose.Attribute",
            "Joose.Role",
            "Joose.Module",
            "Joose.Prototype",
            "Joose.TypedMethod"
        ]
    },

    loadComponents: function (basePath) {
        var html = "";
        Joose.A.each(this.components(), function (name) {
            var url    = ""+basePath + "/" + name.split(".").join("/") + ".js";

            html += '<script type="text/javascript" src="'+url+'"></script>'
        })
        document.write(html)
    }
}

Joose.copyObject = function (source, target) {
    var keys = "";
    Joose.O.each(source, function (value, name) {  keys+=", "+name; target[name] = value })
    return target
};



Joose.emptyFunction = function () {};

this.joose = new Joose();

// Rhino is the only popular JS engine that does not traverse objects in insertion order
// Check for Rhino (which uses the global Packages function) and set CHAOTIC_TRAVERSION_ORDER to true
(function () {

    if(
         typeof this["load"] == "function" &&
         (
            typeof this["Packages"] == "function" ||
            typeof this["Packages"] == "object"
         )
   ) {
        joose.CHAOTIC_TRAVERSION_ORDER = true
   }
})()


Joose.bootstrap = function () {
    // Bootstrap
    var BOOT = new Joose.MetaClassBootstrap();

    BOOT.builder    = Joose.MetaClassBootstrap;

    Joose.MetaClass = BOOT.createClass("Joose.MetaClass");

    Joose.MetaClass.meta.addNonJooseSuperClass("Joose.MetaClassBootstrap", BOOT)

    Joose.MetaClass.meta.addMethod("initialize", function () { this._name = "Joose.MetaClass" })

    var META     = new Joose.MetaClass();

    META.builder = Joose.MetaClass;

    Joose.Class  = META.createClass("Joose.Class")
    Joose.Class.meta.addSuperClass(Joose.MetaClass);
    Joose.MetaClass.meta.addMethod("initialize", function () { this._name = "Joose.Class" })

    Joose.Class.create = function (name, optionalConstructor, optionalModule) {
        var aClass      = new this();

        // aClass.builder allows creating more instances of the same meta class
        // Workaround for broken object.constructor implementation.
        aClass.builder  = this;
        var c           = aClass.createClass(name, optionalConstructor, optionalModule)
        c.meta.builder  = this

        return c;
    }
}

Joose.bootstrapCompletedBuilder = function () {
    // Turn Joose.Method into a Joose.Class object
    Joose.Builder.Globals.joosify("Joose.Method", Joose.Method)
    Joose.Builder.Globals.joosify("Joose.Attribute", Joose.Attribute)

}

Joose.bootstrapCompletedClassMethod = function () {
    Joose.Class.meta.addClassMethod("create", Joose.Class.create)
}

Joose.bootstrap3 = function () {
    // make the .meta object circular
}

var Joose_Default_toString = function toString () {
    if(this.stringify) {
        return this.stringify()
    }
    return "a "+ this.meta.className()
}

var Joose_Default_Class_toString = function toString () {
    return this.meta.className()
}

var Joose_Default_Initializer = function initialize (paras) {
    var me = this;
    if(this.meta.isAbstract) {
        var name = this.meta.className();
        throw ""+name+" is an abstract class and may not instantiated."
    }
    var attributes = this.meta.getAttributes();
    for(var i in attributes) {
        if(attributes.hasOwnProperty(i)) {
            var attr = attributes[i];
            attr.doInitialization(me, paras);
        }
    }
}

var Joose_Default_detach = function detach () {
    var meta = this.meta;

    if(meta.isDetached) {
        return // no reason to do it again
    }

    var c    = meta.makeAnonSubclass()

    c.meta.isDetached = true;

    // appy the role to the anonymous class
    // swap meta class of object with new instance
    this.meta      = c.meta;
    // swap __proto__ chain of object to its new class
    // unfortunately this is not available in IE :(
    // object.__proto__ = c.prototype

    this.constructor = c;

    var proto;

    // Workaround for IE and opera to enable prototype extention via the meta class (by making them identical :)
    // This however makes Role.unapply impossible
    if(!this.__proto__) {
        proto = this
    } else {
        proto   = {};
        Joose.copyObject(this, proto)
    }


    c.prototype    = proto;
    this.__proto__ = c.prototype
    return
}

/**
 * @name Joose.Class
 * @constructor
 */
/*
 * Joose.MetaClassBootstrap is used to bootstrap the Joose.Class with a regular JS constructor
 */
/** ignore */ // Do not display the Bootstrap classes in the docs
Joose.MetaClassBootstrap = function () {
    this._name            = "Joose.MetaClassBootstrap";
    this.methodNames      = [];
    this.attributeNames   = ["_name", "isAbstract", "isDetached", "methodNames", "attributeNames", "methods", "parentClasses", "roles", "c"];
    this.attributes       = {};
    this.methods          = {};
    this.classMethods     = {};
    this.parentClasses    = [];
    this.roles            = []; // All roles
    this.myRoles          = []; // Only roles applied to me directly
    this.isAbstract       = false;
    this.isDetached       = false;
}
/** @ignore */
Joose.MetaClassBootstrap.prototype = {

    toString: function () {
        if(this.meta) {
            return "a "+this.meta.className();
        }
        return "NoMeta"
    },

    /**
     * Returns the name of the class
     * @name className
     * @function
     * @memberof Joose.Class
     */
    /** @ignore */
    className: function () {
        return this._name
    },

    /**
     * Returns the name of the class (alias to className())
     * @name getName
     * @function
     * @memberof Joose.Class
     */
    /** @ignore */
    getName: function () {
        return this.className()
    },

    /**
     * Creates a new empty meta class object
     * @function
     * @name newMetaClass
     * @memberof Joose.Class
     */
    /** @ignore */
    newMetaClass: function () {

        var me  = this;

        var metaClassClass = this.builder;

        var c     = new metaClassClass();
        c.builder = metaClassClass;
        c._name   = this._name

        c.methodNames    = [];
        c.attributeNames = [];
        c.methods        = {};
        c.classMethods   = {};
        c.parentClasses  = [];
        c.roles          = [];
        c.myRoles        = [];
        c.attributes     = {};

        var myMeta = this.meta;
        if(!myMeta) {
            myMeta = this;
        }

        c.meta = myMeta

        return c
    },

    /**
     * Creates a new class object
     * @function
     * @name createClass
     * @param {function} optionalConstructor If provided will be used as the class constructor (You should not need this)
     * @param {Joose.Module} optionalModuleObject If provided the Module's name will be prepended to the class name
     * @memberof Joose.Class
     */
    /** @ignore */
    createClass:    function (name, optionalConstructor, optionalModuleObject) {
        var meta  = this.newMetaClass();

        var c;

        if(optionalConstructor) {
            c = optionalConstructor
        } else {
            c = this.defaultClassFunctionBody()

            if(optionalModuleObject) {
                optionalModuleObject.addElement(c)
                // meta.setModule(optionalModuleObject)
            }
        }

        c.prototype.meta = meta
        c.meta    = meta;
        if(name == null) {
            meta._name = "__anonymous__"
        } else {
            var className = name;
            if(optionalModuleObject) {
                className = optionalModuleObject.getName() + "." + name
            }
            meta._name = className;
        }
        meta.c = c;

        // store them in the global object if they have no namespace
        // They will end up in the Module __JOOSE_GLOBAL__
        if(!optionalModuleObject) {
            // Because the class Joose.Module might not exist yet, we use this temp store
            // that will later be in the global module
            joose.globalObjects.push(c)
        }

        meta.addInitializer();
        meta.addToString();
        meta.addDetacher();

        return c;
    },

    buildComplete: function () {
        // may be overriden in sublass
    },

    // intializes a class from the class definitions
    initializeFromProps: function (props) {
        this._initializeFromProps(props)
    },

    _initializeFromProps: function (props) {
        var me = this;
        if(props) {

            if(joose.CHAOTIC_TRAVERSION_ORDER) {
                Joose.A.each(["isa", "does", "has", "method", "methods"], function (name) {
                    if(name in props) {
                        var value = props[name];
                        me._initializeFromProp(name, value, props)
                        delete props[name]
                    }
                })
            }

            // For each property of the class constructor call the builder
            Joose.O.eachSafe(props, function (value, name) {
                me._initializeFromProp(name, value, props)
            })

            for(var i = 0; i < this.roles.length; i++) {
                var role = this.roles[i];
                role.meta.applyMethodModifiers(this.c)
            }

            me.buildComplete();
            me.validateClass();
        }
    },

    _initializeFromProp: function (propName, value, props) {
        var paras             = value;
        var customBuilderName = "handleProp"+propName;
        // if the meta class of the current class implements handleProp+nameOfBuilder we use that
        if(this.meta.can(customBuilderName)) {
            this[customBuilderName](paras, props)
        } else { // Otherwise use a builder from this file
            throw new Error("Called invalid builder "+propName+" while creating class "+this.className())
        }
    },

    /**
     * Returns a new instance of the class that this meta class instance is representing
     * @function
     * @name instantiate
     * @memberof Joose.Class
     */
    instantiate: function () {
        //var o = new this.c.apply(this, arguments);

        // Ough! Calling a constructor with arbitrary arguments hack
        var f = function () {};
        f.prototype = this.c.prototype;
        f.prototype.constructor = this.c;
        var obj = new f();
        this.c.apply(obj, arguments);
        return obj;
    },

    /**
     * Returns the default constructor function for new classes. You might want to override this in derived meta classes
     * Default calls initialize on a new object upon construction.
     * The class object will stringify to it's name
     * @function
     * @name defaultClassFunctionBody
     * @memberof Joose.Class
     */
    /** @ignore */
    defaultClassFunctionBody: function () {
        var f = function () {
            this.initialize.apply(this, arguments);
        };
        joose.addToString(f, Joose_Default_Class_toString)
        return f;
    },

    /**
     * Adds a toString method to a class
     * The default toString method will call the method stringify if available.
     * This make overriding stringification easier because toString cannot
     * be reliably overriden in some JS implementations.
     * @function
     * @name addToString
     * @memberof Joose.Class
     */
    /** @ignore */
    addToString: function () {
        this.addMethod("toString", Joose_Default_toString)
    },

    /**
     * Adds the method returned by the initializer method to the class
     * @function
     * @name addInitializer
     * @memberof Joose.Class
     */
    /** @ignore */
    addInitializer: function () {
        if(!this.c.prototype.initialize) {
            this.addMethod("initialize", this.initializer())
        }
    },

    /**
     * Adds a toString method to a class
     * @function
     * @name initializer
     * @memberof Joose.Class
     */
    /** @ignore */
    initializer: function () {
        return Joose_Default_Initializer;
    },

    dieIfString: function (thing) {
        if(Joose.S.isString(thing)) {
            throw new TypeError("Parameter must not be a string.")
        }
    },

    addRole: function (roleClass) {
        this.dieIfString(roleClass);
        var c = this.getClassObject();
        if(roleClass.meta.apply(c)) {
            this.roles.push(roleClass);
            this.myRoles.push(roleClass);
        }

    },

    getClassObject: function () {
        return this.c
    },

    classNameToClassObject: function (className) {
        var top    = joose.top;
        var parts  = className.split(".");
        var object = top;
        for(var i = 0; i < parts.length; i++) {
            var part = parts[i];
            object   = object[part];
            if(!object) {
                throw "Unable to find class "+className
            }
        }
        return object
    },

    addNonJooseSuperClass: function (name, object) {

        var pseudoMeta     = new Joose.MetaClassBootstrap();
        pseudoMeta.builder = Joose.MetaClassBootstrap;
        var pseudoClass    = pseudoMeta.createClass(name)

        Joose.O.each(object, function(value, name) {
            if(typeof(value) == "function") {
                pseudoClass.meta.addMethod(name, value)
            } else {
                pseudoClass.meta.addAttribute(name, {init: value})
            }
        })

        this.addSuperClass(pseudoClass);
    },

    addSuperClass:    function (classObject) {
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

        // Roles
        var roles = classObject.meta.roles
        for(var i = 0, len = roles.length; i < len; ++i) {
            var role = roles[i]
            me.roles.push(role)
        }

        this.parentClasses.unshift(classObject)
    },

    _fixMetaclassIncompatability: function (superClass) {

        var superMeta     = superClass.meta;
        var superMetaName = superMeta.meta.className();

        if(
          superMetaName == "Joose.Class"     ||
          superMetaName == "Joose.MetaClass" ||
          superMetaName == "Joose.MetaClassBootstrap") {
            return
        }

        // we are compatible
        if(this.meta.meta.isa(superMeta)) {
            return
        }

        // fix this into becoming a superMeta
        var patched = superMeta.meta.instantiate(this);

        for(var i in patched) {
            this[i] = patched[i]
        }
    },

    isa:            function (classObject) {
        this.dieIfString(classObject);
        var name = classObject.meta.className()
        // Same type
        if(this.className() === name) {
            return true
        }
        // Look up into parent classes
        for(var i = 0, len = this.parentClasses.length; i < len; ++i) {
            var parent = this.parentClasses[i].meta
            if(parent.className() === name) {
                return true
            }
            if(parent.isa(classObject)) {
                return true
            }
        }
        return false
    },

    wrapMethod:  function (name, wrappingStyle, func, notPresentCB) {

        var orig = this.getMethodObject(name);
        if(orig) {
            this.addMethodObject( orig[wrappingStyle](func) )
        } else {
            if(notPresentCB) {
                notPresentCB()
            } else {
                throw new Error("Unable to apply "+wrappingStyle+" method modifier because method "+name+" does not exist");
            }
        }
    },

    dispatch:        function (name) {
        return this.getMethodObject(name).asFunction()
    },

    hasMethod:         function (name) {
        return this.methods[name] != null || this.classMethods[name] != null
    },

    addMethod:         function (name, func, props) {
        var m = new Joose.Method(name, func, props);

        this.addMethodObject(m)
    },

    addClassMethod:         function (name, func, props) {
        var m = new Joose.ClassMethod(name, func, props);

        this.addMethodObject(m)
    },

    addMethodObject:         function (method) {
        var m              = method;
        // optimized because very heavily used
        var name           = m.getName === Joose.Method.prototype.getName ? m._name : m.getName();

        var body = m._body;
        if(!body.displayName) { // never overwrite this. We want to know where the method is defined
            var className = this.className === Joose.MetaClassBootstrap.prototype.className ? this._name : this.className()
            body.displayName =  className + "." + name+"()";
        }

        if(!this.methods[name] && !this.classMethods[name]) {
            this.methodNames.push(name);
        }
        if(m._isClassMethod) {
            this.classMethods[name] = m;
        } else {
            this.methods[name] = m;
        }

        method.addToClass(this.c)
    },

    attributeMetaclass: function () {
        return Joose.Attribute
    },

    addAttribute:     function (name, props) {

        var metaclass = this.attributeMetaclass();

        if(props && props.metaclass) {
            metaclass = props.metaclass
        }

        var at = new metaclass(name, props);

        at.apply(this.c)
    },

    getAttributes: function () {
        return this.attributes
    },

    getAttribute: function (name) {
        return this.attributes[name]
    },

    setAttribute: function (name, attributeObject) {
        return this.attributes[name] = attributeObject
    },

    getMethodObject: function (name) {
        return this.methods[name]
    },

    getClassMethodObject: function (name) {
        return this.classMethods[name]
    },

    getAttributeNames: function () {
        return this.attributeNames;
    },

    getInstanceMethods: function () {
        var a = [];
        Joose.O.eachSafe(this.methods, function (m) {
            a.push(m)
        })
        return a
    },

    getClassMethods: function () {
        var a = [];
        Joose.O.eachSafe(this.classMethods, function (m) {
            a.push(m)
        })
        return a
    },

    getSuperClasses:    function () {
        return this.parentClasses;
    },

    getSuperClass:    function () {
        return this.parentClasses[0];
    },

    getRoles:    function () {
        return this.roles;
    },

    getMethodNames:    function () {
        return this.methodNames;
    },

    makeAnonSubclass: function () {
        var c    = this.createClass(this.className()+"__anon__"+joose.anonymouseClassCounter++);
        c.meta.addSuperClass(this.getClassObject());

        return c;
    },

    addDetacher: function () {
        this.addMethod("detach", Joose_Default_detach);
    },

    /**
     * Throws an exception if the class does not implement all methods required by it's roles
     * @function
     * @name validateClass
     * @memberof Joose.Class
     */
    validateClass: function () {
        var c  = this.getClassObject();
        var me = this;

        // Test whether all rows are fully implemented.
        var throwException = true;
        Joose.A.each(this.roles, function(role) {
              role.meta.isImplementedBy(c, throwException)
        })
    },

            /**
     * Returns true if the class implements the method
     * @function
     * @name can
     * @param {string} methodName The method
     * @memberof Joose.Class
     */
    can: function (methodName) {
        var method = this.methods[methodName];
        if(!method) {
            return false
        }
        return true
    },

    classCan: function (methodName) {
        var method = this.classMethods[methodName];
        if(!method) {
            return false
        }
        return true
    },


    /**
     * Returns true if the class implements a Role
     * @function
     * @name does
     * @param {Joose.Class} methodName The class object
     * @memberof Joose.Class
     */
    does: function (roleObject) {

        for(var i = 0; i < this.roles.length; i++) {
            if(roleObject === this.roles[i]) {
                return true
            }
        }

        // dive into roles to find roles implemented by my roles
        for(var i = 0; i < this.roles.length; i++) {
            if(this.roles[i].meta.does(roleObject)) {
                return true
            }
        }

        return false
        // return classObject.meta.implementsMyMethods(this.getClassObject())
    },

    /**
     * Returns true if the given class implements all methods of the class
     * @function
     * @name does
     * @param {Joose.Class} methodName The class object
     * @memberof Joose.Class
     */
    implementsMyMethods: function (classObject) {
        var complete = true
        // FIXME buggy if class methods are involved. Should roles have class methods?
        Joose.A.each(this.getMethodNames(), function (value) {
            var found = classObject.meta.can(value)
            if(!found) {
                complete = false
            }
        })
        return complete
    },

    // Class builders:

    /**
     * Tells a role that the method name must be implemented by all classes that implement the role
     * @function
     * @param methodName {string} Name of the required method name
     * @name requires
     * @memberof Joose.Builder
     */
    /** @ignore */
    handleProprequires:    function (methodName) {
        var me = this;
        if(!this.meta.isa(Joose.Role)) {
            throw("Keyword 'requires' only available classes with a meta class of type Joose.Role")
        }
        if(methodName instanceof Array) {
            Joose.A.each(methodName, function (name) {
                me.addRequirement(name)
            })
        } else {
            me.addRequirement(methodName)
        }
    },

    handlePropisAbstract: function (bool) {
        this.isAbstract = bool
    },


    /**
     * Class builder method
     * Defines the super class of the class
     * @function
     * @param classObject {Joose.Class} The super class
     * @name isa
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropisa:    function (classObject) {
        if(classObject == null) {
            throw new Error("Super class is null")
        }
        this.addSuperClass(classObject)
    },
    /**
     * Class builder method
     * Defines a role for the class
     * @function
     * @param classObject {Joose.Role} The role
     * @name does
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropdoes:    function (role) {
        var me = this;
        if(role instanceof Array) {
            Joose.A.each(role, function (aRole) {
                me.addRole(aRole)
            })
        } else {
            me.addRole(role)
        }

    },

    /**
     * Class builder method
     * Defines attributes for the class
     * @function
     * @param classObject {object} Maps attribute names to properties (See Joose.Attribute)
     * @name has
     * @memberof Joose.Builder
     */
    /** @ignore */
    handleProphas:    function (map) {
        var me = this;
        if(typeof map == "string") {
            var name  = arguments[0];
            var props = arguments[1];
            me.addAttribute(name, props)
        } else { // name is a map
            Joose.O.eachSafe(map, function (props, name) {
                me.addAttribute(name, props)
            })
        }
    },

    /**
     * @ignore
     */
    handlePropmethod: function (name, func, props) {
        this.addMethod(name, func, props)
    },

    /**
     * Class builder method
     * Defines methods for the class
     * @function
     * @param classObject {object} Maps method names to function bodies
     * @name methods
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropmethods: function (map) {
        var me = this
        Joose.O.eachSafe(map, function (func, name) {
            // if func is already a method object, we use that
            if(typeof func !== "function") {
                var props  = func; // the function must now be a property hash
                var method;
                method = Joose.TypedMethod.newFromProps(name, props)
                me.addMethodObject(method)
            }
            // otherwise we create a method object from the function
            else {
                me.addMethod(name, func)
            }
        })
    },

    /**
     * Class builder method
     * Defines class methods for the class
     * @function
     * @param classObject {object} Maps class method names to function bodies
     * @name classMethods
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropclassMethods: function (map) {
        var me = this;
        Joose.O.eachSafe(map, function (func, name2) {
            me.addMethodObject(new Joose.ClassMethod(name2, func))
        })
    },

    /**
     * Class builder method
     * Defines workers for the class (The class must have the meta class Joose.Gears)
     * @function
     * @param classObject {object} Maps method names to function bodies
     * @name workers
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropworkers: function (map) {
        var me = this;
        Joose.O.eachSafe(map, function (func, name) {
            me.addWorker(name, func)
        })
    },

    /**
     * Class builder method
     * Defines before method modifieres for the class.
     * The defined method modifiers will be called before the method of the super class.
     * The return value of the method modifier will be ignored
     * @function
     * @param classObject {object} Maps method names to function bodies
     * @name before
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropbefore: function(map) {
        var me = this
        Joose.O.eachSafe(map, function (func, name) {
            me.wrapMethod(name, "before", func);
        })
    },

    /**
     * Class builder method
     * Defines after method modifieres for the class.
     * The defined method modifiers will be called after the method of the super class.
     * The return value of the method modifier will be ignored
     * @function
     * @param classObject {object} Maps method names to function bodies
     * @name after
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropafter: function(map) {
        var me = this
        Joose.O.eachSafe(map, function (func, name) {
            me.wrapMethod(name, "after", func);
        })
    },

    /**
     * Class builder method
     * Defines around method modifieres for the class.
     * The defined method modifiers will be called instead of the method of the super class.
     * The orginial function is passed as an initial parameter to the new function
     * @function
     * @param classObject {object} Maps method names to function bodies
     * @name around
     * @memberof Joose.Builder
     */
    /** @ignore */
    handleProparound: function(map) {
        var me = this
        Joose.O.eachSafe(map, function (func, name) {
            me.wrapMethod(name, "around", func);
        })
    },

    /**
     * Class builder method
     * Defines override method modifieres for the class.
     * The defined method modifiers will be called instead the method of the super class.
     * You can call the method of the super class by calling this.SUPER(para1, para2)
     * @function
     * @param classObject {object} Maps method names to function bodies
     * @name override
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropoverride: function(map) {
        var me = this
        Joose.O.eachSafe(map, function (func, name) {
            me.wrapMethod(name, "override", func);
        })
    },

    /**
     * Class builder method
     * Defines augment method modifieres for the class.
     * These method modifiers will be called in "most super first" order
     * The methods may call this.INNER() to call the augement method in it's sup class.
     * @function
     * @param classObject {object} Maps method names to function bodies
     * @name augment
     * @memberof Joose.Builder
     */
    /** @ignore */
    handlePropaugment: function(map) {
        var me = this
        Joose.O.eachSafe(map, function (func, name) {
            me.wrapMethod(name, "augment", func, function () {
                me.addMethod(name, func)
            });
        })
    },

    /**
     * @ignore
     */
    handlePropdecorates: function(map) {
        var me = this
        Joose.O.eachSafe(map, function (classObject, attributeName) {
            me.decorate(classObject, attributeName)
        })
    }
};

// See http://code.google.com/p/joose-js/wiki/JooseAttribute
Joose.Attribute = function (name, props) {
    this.initialize(name, props)
}

Joose.Attribute.prototype = {

    _name:  null,
    _props: null,

    getName:        function () { return this._name },
    getProps:       function () { return this._props },
    getStoreAsName: function () { return this._name }, // easy access point for modifying the default attribute storage location

    initialize: function (name, props) {
        this._name  = name;
        this.setProps(props);
    },

    setProps: function (props) {
        if(props) {
            this._props = props
        } else {
            this._props = {};
        }
    },

    getIsa: function () {
        var props = this.getProps();
        if("isa" in props && props.isa == null) {
            throw new Error("You declared an isa property but the property is null.")
        }
        if(props.isa) {
            if(!props.isa.meta) {
                return props.isa()
            }
            return props.isa
        }
        return
    },

    addSetter: function (classObject) {
        var meta        = classObject.meta;
        var name        = this.getName();
        var storeAsName = this.getStoreAsName();
        var props       = this.getProps();

        var setterName = this.setterName();

        if(meta.can(setterName)) { // do not override methods
            return
        }

        var isa   = this.getIsa();

        var func;
        if(isa) {

            // This setter is used if the attribute is constrained with an isa property in the attribute initializer
            func = function setterWithIsaCheck (value, errorHandler) {
//                value = checkerFunc(value, errorHandler)
                this[storeAsName] = value
                return this;
            }
        } else {
            func = function setter (value) {
                this[storeAsName] = value
                return this;
            }
        }
        meta.addMethod(setterName, func);
    },


    addGetter: function (classObject) {
        var meta        = classObject.meta;
        var name        = this.getName();
        var storeAsName = this.getStoreAsName();
        var props       = this.getProps()

        var getterName = this.getterName();

        if(meta.can(getterName)) { // never override a method
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

        meta.addMethod(getterName, func);
    },

    initializerName: function () {
        return this.toPublicName()
    },

    getterName: function () {
        if(this.__getterNameCache) { // Cache the getterName (very busy function)
            return this.__getterNameCache
        }
        this.__getterNameCache = "get"+Joose.S.uppercaseFirst(this.toPublicName())
        return this.__getterNameCache;
    },

    setterName: function () {
        if(this.__setterNameCache) { // Cache the setterName (very busy function)
            return this.__setterNameCache
        }
        this.__setterNameCache = "set"+Joose.S.uppercaseFirst(this.toPublicName())
        return this.__setterNameCache;
    },

    isPrivate: function () {
        return this.getName().charAt(0) == "_"
    },

    toPublicName: function () {

        if(this.__publicNameCache) { // Cache the publicName (very busy function)
            return this.__publicNameCache
        }

        var name = this.getName();
        if(this.isPrivate()) {
            this.__publicNameCache = name.substr(1)
            return this.__publicNameCache;
        }
        this.__publicNameCache = name
        return this.__publicNameCache
    },

    handleIs: function (classObject) {
        var meta  = classObject.meta;
        var name  = this.getName();
        var props = this.getProps();

        var is    = props.is;

        if(is == "rw" || is == "ro") {
            this.addGetter(classObject);
        }
        if(is == "rw") {
            this.addSetter(classObject)
        }
    },

    handleInit: function (classObject) {
        var props       = this.getProps();
        var name        = this.getName();
        var storeAsName = this.getStoreAsName();

        classObject.prototype[storeAsName]     = null;
        if(typeof props.init != "undefined") {
            var val = props.init;
            var type = typeof val;

            classObject.prototype[storeAsName] = val;
        }
    },

    handleProps: function (classObject) {
        this.handleIs(classObject);
        this.handleInit(classObject)
    },

    apply: function (classObject) {

        var meta  = classObject.meta;
        var name  = this.getName();

        this.handleProps(classObject)

        meta.attributeNames.push(name)

        meta.setAttribute(name, this)
        meta.attributes[name] = this;
    }


}

// See http://code.google.com/p/joose-js/wiki/JooseMethod
Joose.Method = function (name, func, props) {
    this.initialize(name, func, props)
}

Joose.Method.prototype = {

    _name: null,
    _body: null,
    _props: null,
    _isFromSuperClass: false,
    _isClassMethod: false,

    getName:    function () { return this._name },
    getBody:    function () { return this._body },
    getProps:   function () { return this._props },

    isFromSuperClass: function () {
        return this._isFromSuperClass
    },

    setIsFromSuperClass: function (bool) {
        this._isFromSuperClass = bool
    },

    copy: function () {
        // Hardcode class name because at this point this.meta.instantiate might not work yet
        // this is later overridden in the file Joose/Method.js
        return new Joose.Method(this.getName(), this.getBody(), this.getProps())
    },

    initialize: function (name, func, props) {
        this._name  = name;
        this._body  = func;
        this._props = props;

        func.name   = name

        func.meta   = this
    },

    isClassMethod: function () { return this._isClassMethod },

    apply:    function (thisObject, args) {
        return this._body.apply(thisObject, args)
    },

    addToClass: function (c) {
        // optimized due to heavy calls
        var base = Joose.Method.prototype;
        var name = this.getName === base.getName ? this._name : this.getName();
        var func = this.asFunction === base.asFunction ? this._body : this.asFunction()
        c.prototype[name] = func
    },


    // direct call
    asFunction:    function () {
        return this._body
    }
}



Joose.bootstrap()
})();

// ##########################
// File: Joose/Builder.js
// ##########################
// Could be refactored to a Joose.Class (by manually building the class)

/**
 * Assorted tools to build a class
 *
 * The functions Class(), Module() and joosify() are global. All other methods
 * may be used inside Class definitons like this:
 *
 * <pre>
 * Module("com.test.me", function () {
 *   Class("MyClass", {
 *     isa: SuperClass,
 *     methods: {
 *       hello: function () { alert('world') }
 *     }
 *   })
 * })
 * </pre>
 * @constructor
 */



Joose.Builder = function () {
    /** @ignore */
    this.globalize = function () {
        Joose.O.each(Joose.Builder.Globals, function (func, name) {
            var globalName = "Joose"+name
            if(typeof joose.top[name] == "undefined") {
                joose.top[name] = func
            }

            joose.top[globalName] = func
        });
    }
}

/** @ignore */
Joose.Builder.Globals = {
    /**
     * Global function that creates or extends a module
     * @function
     * @param name {string} Name of the module
     * @param functionThatCreatesClassesAndRoles {function} Pass a function reference that calls Class(...) as often as you want. The created classes will be put into the module
     * @name Module
     */
    /** @ignore */
    Module: function (name, functionThatCreatesClassesAndRoles) {
        return Joose.Module.setup(name, functionThatCreatesClassesAndRoles)
    },

    Role: function (name, props) {
        if(!props.meta) {
            props.meta = Joose.Role;
        }
        return JooseClass(name, props)
    },

    Prototype: function (name, props) {
        if(!props.meta) {
            props.meta = Joose.Prototype;
        }
        return JooseClass(name, props);
    },

    /**
     * Global function that creates a class (If the class already exists it will be extended)
     * @function
     * @param name {string} Name of the the class
     * @param props {object} Declaration if the class. The object keys are used as builder methods. The values are passed as arguments to the builder methods.
     * @name Class
     */
    /** @ignore */
    Class:    function (name, props) {

        var c = null;

        if(name) {
            var className  = name;
            if(joose.currentModule) {
                className  = joose.currentModule.getName() + "." + name
            }
            var root       = joose.top;
            var parts      = className.split(".")

            for(var i = 0, len = parts.length; i < len; ++i) {
                root = root[parts[i]]
            }
            c = root;
        }

        if(c == null) {

            var metaClass;

            /* Use the custom meta class if provided */
            if(props && props.meta) {
                metaClass = props.meta
                delete props.meta
            }
            /* Otherwise use the meta class of the parent class (If there is one)
             * If the parent class is Joose.Class, we don't change the meta class but use the default
             * because that Joose.Class's meta class is only needed for bootstrapping
             * purposes. */
            else if(props && props.isa && props.isa != Joose.Class) {
                metaClass = props.isa.meta.builder
                //alert(name + metaClass + props.isa.meta)
            }
            /* Default meta class is Joose.Class */
            else {
                metaClass   = Joose.Class;
            }

            var c = metaClass.create(name, null, joose.currentModule)

            var className   = c.meta.className()

            if(name && className) {
                var root = joose.top;
                var n = className+"";
                var parts = n.split(".");
                for(var i = 0, len = parts.length; i < len - 1; ++i) {
                    if(root[parts[i]] == null) {
                        root[parts[i]] = {};
                    }
                    root = root[parts[i]];
                }
                root[parts[parts.length - 1]] = c
            }

        }

        c.meta.initializeFromProps(props)

        return c
    },

    /**
     * Global function to turn a regular JavaScript constructor into a Joose.Class
     * @function
     * @param name {string} Name of the class
     * @param props {function} The constructor
     * @name joosify
     */
    /** @ignore */
    joosify: function (standardClassName, standardClassObject) {
        var c         = standardClassObject;
        var metaClass = new Joose.Class();
        metaClass.builder = Joose.Class;

        c.toString = function () { return this.meta.className() }
        c             = metaClass.createClass(standardClassName, c)

        var meta = c.meta;

        for(var name in standardClassObject.prototype) {
            if(name == "meta") {
                continue
            }
            var value = standardClassObject.prototype[name]
            if(typeof(value) == "function") {
                meta.addMethod(name, value)
            } else {
                var props = {};
                if(typeof(value) != "undefined") {
                    props.init = value
                }
                meta.addAttribute(name, props)
            }
        }

        return c
    },

    /** @ignore */
    rw: "rw",
    /** @ignore */
    ro: "ro"
};

joose.init();
Joose.bootstrapCompletedBuilder();


// ##########################
// File: Joose/Class.js
// ##########################

// ##########################
// File: Joose/Method.js
// ##########################
/*
 * A class for methods
 * Originally defined in Joose.js
 *
 * See http://code.google.com/p/joose-js/wiki/JooseMethod
 */

(function (Class) {

Class("Joose.Method", {
    methods: {

        copy: function () {
            return new this.meta.c(this.getName(), this.getBody(), this.getProps())
        },

        // creates a new method object with the same name
        _makeWrapped: function (func) {
            return new this.meta.c(this.getName(), func); // Should there be , this.getProps() ???
        },

        around: function (func) {
            var orig = this.getBody();
            return this._makeWrapped(function aroundWrapper () {
                var me = this;
                var bound = function () { return orig.apply(me, arguments) }
                return func.apply(this, Joose.A.concat([bound], arguments))
            })
        },
        before: function (func) {
            var orig = this.getBody();
            return this._makeWrapped(function beforeWrapper () {
                func.apply(this, arguments)
                return orig.apply(this, arguments);
            })
        },
        after: function (func) {
            var orig = this.getBody();
            return this._makeWrapped(function afterWrapper () {
                var ret = orig.apply(this, arguments);
                func.apply(this, arguments);
                return ret
            })
        },

        override: function (func) {
            var orig = this.getBody();
            return this._makeWrapped(function overrideWrapper () {
                var me      = this;
                var bound   = function () { return orig.apply(me, arguments) }
                var before  = this.SUPER;
                this.SUPER  = bound;
                var ret     = func.apply(this, arguments);
                this.SUPER  = before;
                return ret
            })
        },

        augment: function (func) {
            var orig = this.getBody();
            orig.source = orig.toString();
            return this._makeWrapped(function augmentWrapper () {
                var exe       = orig;
                var me        = this;
                var inner     = func
                inner.source  = inner.toString();
                if(!this.__INNER_STACK__) {
                    this.__INNER_STACK__ = [];
                };
                this.__INNER_STACK__.push(inner)
                var before    = this.INNER;
                this.INNER    = function () {return  me.__INNER_STACK__.pop().apply(me, arguments) };
                var ret       = orig.apply(this, arguments);
                this.INNER    = before;
                return ret
            })
        }
    }
})

})(JooseClass);

// ##########################
// File: Joose/ClassMethod.js
// ##########################
(function (Class) {

Class("Joose.ClassMethod", {
    isa: Joose.Method,
    after: {
        initialize: function () {
            this._isClassMethod = true
        }
    },
    methods: {
        addToClass: function (c) {
            c[this.getName()] = this.asFunction()
        },

        copy: function () {
            return new Joose.ClassMethod(this.getName(), this.getBody(), this.getProps())
        }
    }
})

Joose.bootstrapCompletedClassMethod()

})(JooseClass);

// ##########################
// File: Joose/Attribute.js
// ##########################
/*
 * This handles the following attribute properties
 *  * init with function value in non-lazy initialization
 *  * required attributes in initializaion
 *  * handles for auto-decoration
 *  * predicate for attribute availability checks
 *
 *
 * See http://code.google.com/p/joose-js/wiki/JooseAttribute
 */

(function (Class) {
Class("Joose.Attribute", {
    after: {
        handleProps: function (classObject) {
            this.handleHandles(classObject);
            this.handlePredicate(classObject);
        }
    },
    methods: {

        isPersistent: function () {
            var props = this.getProps()
            if(props.persistent == false) {
                return false
            }
            return true
        },

        doInitialization: function (object, paras) {
            var   name  = this.initializerName();
            var  _name  = this.getName();
            var __name  = this.getStoreAsName();
            var value;
            var isSet  = false;
            if(typeof paras != "undefined" && typeof paras[name] != "undefined") {
                value  = paras[name];
                isSet  = true;
            } else {
                var props = this.getProps();

                var init  = props.init;

                if(typeof init == "function" && !props.lazy) {
                    // if init is not a function, we have put it in the prototype, so it is already here
                    value = init.call(object)
                    isSet = true
                } else {
                    // only enforce required property if init is not run
                    if(props.required) {
                        throw "Required initialization parameter missing: "+name + "(While initializing "+object+")"
                    }
                }
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

        handleHandles: function (classObject) {
            var meta  = classObject.meta;
            var name  = this.getName();
            var props = this.getProps();

            var handles = props.handles;
            var isa     = props.isa

            if(handles) {
                if(handles == "*") {
                    if(!isa) {
                        throw "I need an isa property in order to handle a class"
                    }

                    // receives the name and should return a closure
                    var optionalHandlerMaker = props.handleWith;

                    meta.decorate(isa, name, optionalHandlerMaker)
                }
                else {
                    throw "Unsupported value for handles: "+handles
                }

            }
        },

        handlePredicate: function (classObject) {
            var meta  = classObject.meta;
            var name  = this.getName();
            var props = this.getProps();

            var predicate = props.predicate;

            var getter    = this.getterName();

            if(predicate) {
                meta.addMethod(predicate, function () {
                    var val = this[getter]();
                    return val ? true : false
                })
            }
        }
    }
})
})(JooseClass);

// ##########################
// File: Joose/Role.js
// ##########################

/*
 * An Implementation of Traits
 * see http://www.iam.unibe.ch/~scg/cgi-bin/scgbib.cgi?query=nathanael+traits+composable+units+ecoop
 *
 * Current Composition rules:
 * - At compile time we override existing (at the time of rule application) methods
 * - At runtime we dont
 */

(function (Class) {

Class("Joose.Role", {
    isa: Joose.Class,
    has: ["requiresMethodNames", "methodModifiers", "metaRoles"],
    methods: {

        // Add a method modifier that will be applied to classes implementing this role.
        wrapMethod: function (name, wrappingStyle, func, notPresentCB) {
            // queue arguments given to this function for later application to actual class
            this.methodModifiers.push(arguments)
            var test = this.methodModifiers
        },

        requiresMethod: function (methodName) {
            var bool = false;
            Joose.A.each(this.requiresMethodNames, function (name) {
                if(methodName == name) {
                    bool = true
                }
            })

            return bool
        },

        addInitializer: Joose.emptyFunction,

        // Roles can not be instantiated
        defaultClassFunctionBody: function () {
            var f = function () {
                throw new Error("Roles may not be instantiated.")
            };
            joose.addToString(f, function () { return this.meta.className() })
            return f
        },

        // Roles can not be instantiated
        addSuperClass: function () {
            throw new Error("Roles may not inherit from a super class.")
        },

        initialize: function () {
            this._name               = "Joose.Role"
            this.requiresMethodNames = [];
            this.methodModifiers     = [];
        },

        // Class implementing this role must implement a method named methodName
        addRequirement: function (methodName) {
            this.requiresMethodNames.push(methodName)
        },

        // Experimental method to unapply classes from roles.
        // Only works on roles that were applied at runtime
        // Currently does not work in IE (depends on __proto__)
        unapply: function (object) {
            if(!joose.isInstance(object)) {
                throw new Error("You way only remove roles from instances.")
            }
            if(!object.meta.isDetached) {
                throw new Error("You may only remove roles that were applied at runtime")
            }

            var role  = this.getClassObject()

            var roles = object.meta.myRoles; // myRoles!!!
            var found = false;
            var otherRoles = [];
            for(var i = 0; i < roles.length; i++) {
                if(roles[i] === role) {
                    found = true;
                } else {
                    otherRoles.push(roles[i])
                }
            }
            if(!found) {
                throw new Error("The role "+this.className()+" was not applied to the object at runtime")
            }

            var superClass     = object.meta.getSuperClass();
            var c              = superClass.meta.makeAnonSubclass();


            // rebless object
            /*if(typeof(object.__proto__) != "undefined") {
                object.__proto__ = c.prototype
            } else {   // Workaround for IE:
            */

            var test = new c()

            // add all roles except the one that we are removing
            for(var i = 0; i < otherRoles.length; i++) {
                var role = otherRoles[i]
                c.meta.addRole(role)
            }

            c.prototype        = test

            object.meta        = c.meta;
            object.constructor = c;
            object.__proto__   = test
        },

        addMethodToClass: function (method, classObject) {
            var name = method.getName()
            var cur;
            if(method.isClassMethod()) {
                cur = classObject.meta.getClassMethodObject(name)
            } else {
                cur = classObject.meta.getMethodObject(name)
            }
            // Methods from roles take precedence over methods from a super class
            if(!cur || cur.isFromSuperClass()) {
                classObject.meta.addMethodObject(method)
            }
        },

        addAttributeToClass: function(attr, classObject) {
            var name = attr.getName();
            //don't add the attribute if it already exists in the class
            if (!classObject.meta.getAttribute(name)) {
                this.getAttribute(name).apply(classObject);
            }
        },

        apply: function (object) {

            // XXX ask in #moose whether this is correct
            // A Role should not be applied twice
            if(object.meta.does(this.getClassObject())) {
                return false
            }

            if(joose.isInstance(object)) {
                // Create an anonymous subclass ob object's class

                object.detach();
                object.meta.addRole(this.getClassObject());
                this.applyMethodModifiers(object);
                var throwException = true;
                this.isImplementedBy(object, throwException)
            } else {
                // object is actually a class
                var me    = this;
                var names = me.getMethodNames();
                var attrs = me.getAttributes();
                //alert("Super"+me.name + " -> "+classObject.meta.name +"->" + names)
                Joose.O.each(attrs, function applyAttrs (attr) {
                    me.addAttributeToClass(attr, object);
                });

                Joose.A.each(names, function applyMethod (name) {

                    var m = me.getMethodObject(name)
                    if(m) {
                        me.addMethodToClass(m, object)
                    }

                    m = me.getClassMethodObject(name)
                    if(m) {
                        me.addMethodToClass(m, object)
                    }
                })


                // Meta roles are applied to the meta class of the class that implements us
                if(this.metaRoles) {
                    Joose.A.each(this.metaRoles, function applyMetaRole (role) {
                        role.meta.apply(object.meta)
                    })
                }
            }
            return true
        },

        // should be called by class builder after class has been initialized from props
        applyMethodModifiers: function (object) {

            // Apply method modifiers
            Joose.A.each(this.methodModifiers, function applyMethodModifier (paras) {
                object.meta.wrapMethod.apply(object.meta, paras)
            })
        },

        // Checks whether classObject (can also be any Joose object) implements this role.
        // If second para is true, throws an exception when a method is missing.
        hasRequiredMethods: function (classObject, throwException) {
            var me       = this
            var complete = true
            Joose.A.each(this.requiresMethodNames, function (value) {
                var found = classObject.meta.can(value)
                if(!found) {
                    if(throwException) {
                         throw("Class "+classObject.meta.className()+" does not fully implement the role "+me.className()+". The method is "+value+" missing.")
                    }
                    complete = false
                    return
                }
            })
            return complete
        },

        // This is called by validateClass in Joose.Class.
        // This is not part of apply because apply might be called way before class construction is complete.
        isImplementedBy: function (classObject, throwException) {

            var complete = this.hasRequiredMethods(classObject, throwException);
            if(complete) {
                complete = this.implementsMyMethods(classObject);
            }
            return complete
        },

        // the metaRoles prop allows a role to apply roles to the meta class of the class using the role
        handlePropmetaRoles: function (arrayOfRoles) {
            this.metaRoles = arrayOfRoles;
        }
    }
})

Joose.Role.anonymousClassCounter = 0;

})(JooseClass);

// ##########################

// ##########################
// File: Joose/Decorator.js
// ##########################
(function (Class) {

Class("Joose.Decorator", {
    meta: Joose.Role,
    methods: {
        decorate: function (classObject, attributeName, optionalDelegatorFuncMaker) {
            var me = this;
            var methods = classObject.meta.getInstanceMethods();
            Joose.A.each(methods, function (m) {
                var name    = m.getName();
                var argName = attributeName;
                // only override non existing methods
                if(!me.can(name)) {

                    var func = function () {
                        var d = this[argName];
                        return d[name].apply(d, arguments)
                    }

                    if(optionalDelegatorFuncMaker) {
                        func = optionalDelegatorFuncMaker(name)
                    }

                    me.addMethod(name, func);
                }
            })
        }
    }
})

Joose.Decorator.meta.apply(Joose.Class)

})(JooseClass);

// ##########################
// File: Joose/Module.js
// ##########################

/*
Module("my.namespace", function () {
    Class("Test", {

    })
})
*/
(function (Class) {

// Joose.NameSpace is a pseudo class that makes namespace spots created by Joose.Module discoverable
Joose.NameSpace = function () {}

Class("Joose.Module", {
    has: {
        _name: {
            is: "rw"
        },
        _elements: {
            is: "rw"
        },
        _container: {
            is: "rw"
        }
    },
    classMethods: {
        setup: function (name, functionThatCreatesClassesAndRoles) {
            var me      = this;
            var parts   = name.split(".");
            var object  = joose.top;
            var soFar   = []
            var module;
            for(var i = 0, len = parts.length; i < len; ++i) {
                var part = parts[i];
                if(part == "meta") {
                    throw "Module names may not include a part called 'meta'."
                }
                var cur = object[part];
                soFar.push(part)
                var subName = soFar.join(".")
                if(typeof cur == "undefined") {
                    object[part]      = new Joose.NameSpace();
                    module            = new Joose.Module(subName)
                    module.setContainer(object[part])
                    object[part].meta = module
                    Joose.Module._allModules.push(object[part])

                } else {
                    module = cur.meta;
                    if(
                        i === (len-1) && // only check on last iteration
                        !(module && module.meta && (module.meta.isa(Joose.Module)))) {
                        throw "Trying to setup module "+name+" failed. There is already something else: "+cur
                    }
                }
                object = object[part]
            }
            var before = joose.currentModule
            joose.currentModule = module
            if(functionThatCreatesClassesAndRoles) {
                functionThatCreatesClassesAndRoles(object);
            }
            joose.currentModule = before;
            return object
        },

        getAllModules: function () {
            return this._allModules
        }
    },
    methods: {
        alias: function (destination) {
            var me = this;

            if(arguments.length == 0) {
                return this
            }

            Joose.A.each(this.getElements(), function (thing) {
                var global        = me.globalName(thing.meta.className());

                if(destination[global] === thing) { // already there
                    return
                }
                if(typeof destination[global] != "undefined") {
                    throw "There is already something else in the spot "+global
                }

                destination[global] = thing;
            })
        },

        globalName: function (name) {
            var moduleName = this.getName();
            if(name.indexOf(moduleName) != 0) {
                throw "All things inside me should have a name that starts with "+moduleName+". Name is "+name
            }
            var rest = name.substr(moduleName.length + 1); // + 1 to remove the trailing dot
            if(rest.indexOf(".") != -1) {
                throw "The things inside me should have no more dots in there name. Name is "+rest
            }
            return rest
        },

        removeGlobalSymbols: function () {
            Joose.A.each(this.getElements(), function (thing) {
                var global = this.globalName(thing.getName());
                delete joose.top[global]
            })
        },

        initialize: function (name) {
            this.setElements([])
            this.setName(name);
        },

        isEmpty: function () {
            return this.getElements().length == 0
        },

        addElement: function (ele) {
            if(!(ele || ele.meta)) {
                throw "You may only add things that are Joose objects"
            }
            this._elements.push(ele)
        },

        getNames: function () {
            var names = [];
            Joose.A.each(this.getElements(), function (ele) { names.push(ele.meta.getName()) });
            return names
        }
    }
})
})(JooseClass);

__global__ = {};
__global__.meta = new Joose.Module();
__global__.meta.setName("__global__");
__global__.meta.setContainer(__global__);

Joose.Module._allModules = [__global__];

JooseModule("__global__.nomodule", function () {})
__global__.nomodule.meta._elements = joose.globalObjects;



// ##########################
// File: Joose/Prototype.js
// ##########################

(function (Class) {

Class("Joose.Prototype", {
    isa: Joose.Class,
    override: {
        initializer: function () {
            var init = this.SUPER()
            return function () {
                init.apply(this, arguments)
                var meta = this.meta;
                this.meta = new Joose.PrototypeLazyMetaObjectProxy();
                this.meta.metaObject = meta
                this.meta.object     = this;
            }
        }
    }
})


Class("Joose.PrototypeLazyMetaObjectProxy", {
    has: {
        metaObject: {
            is: "rw",
            isa: Joose.Class,
            handles: "*",
            handleWith: function (name) {
                return function () {
                    // when we are called, turn the objects meta object into the original, detach yourself
                    // and call the original methods
                    var o = this.object;
                    o.meta = this.metaObject;
                    o.detach()
                    o.meta[name].apply(o.meta, arguments)
                }
            }
        },
        object: {
            is: "rw"
        }
    }
})

Joose.bootstrap3()

})(JooseClass);

// ##########################
// File: Joose/TypedMethod.js
// ##########################
(function (Class) {

Class("Joose.TypedMethod", {
    isa: Joose.Method,

    has: {
        types: {
            is:  "rw",
            init: function () { return [] }
        },

        typeCheckers: {
            init: function () { return [] }
        }
    },

    after: {
        setTypes: function () {
            var self         = this;
            var typeCheckers = [];
            var props        = this.getProps();

            Joose.A.each(this.getTypes(), function (type, index) {
                if(type === null) {
                    // if there is no type in a spot, dont push a type checker
                    typeCheckers.push(null)
                } else {
                    typeCheckers.push(Joose.TypeChecker.makeTypeChecker(type, props, "parameter", index))
                }
            })

            this.typeCheckers = typeCheckers
        }
    },

    override: {
        copy: function () {
            var self = this.SUPER();
            // copy types;
            var copy = [].concat(this.types)
            self.setTypes( copy );
            return self;
        }
    },

    methods: {

        wrapTypeChecker: function(body) {
            var self = this;
            return function typeCheckWrapper () {
                var checkers = self.typeCheckers;
                var args = [];
                // iterate over type checkers and arguments
                for(var i = 0, len = checkers.length; i < len; ++i) {
                    var checker = checkers[i]
                    if(checker !== null) {
                        var argument = arguments[i]
                        args[i]      = checker(argument)
                    }
                    // If the type checker is null, dont type check
                    else {
                        args[i]      = arguments[i]
                    }
                }
                return body.apply(this, args)
            }
        },

        // Returns the function that will later be added to objects
        asFunction: function () {
            return this.wrapTypeChecker(this._body)
        }
    },

    classMethods: {
        newFromProps: function (name, props) {
            var method = props.method;
            if(typeof method !== "function") {
                throw new Error("Property method in method declaration ["+name+"] must be a function.")
            }
            var self   = this.meta.instantiate(name, method, props);
            self.setTypes(props.signature);
            return self;
        }
    }

})

})(JooseClass);