Joose.Attribute.prototype.addGetter = function (classObject) {
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
//      if(this.meta._name == 'Widgets.Templates.Catalog') {
//      }
        func = function lazyGetter () {
            var val = this[storeAsName];
            if(typeof val == "function") { //&& val === init) { PREVENTING LAZY OVERRIDE
                this[storeAsName] = val.apply(this)
            }
            return this[storeAsName]
        }
    }

    meta.addMethod(getterName, func);
}