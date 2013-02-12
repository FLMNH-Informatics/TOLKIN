// changes for making getters have same name as attributes
Joose.Attribute.meta.addMethod('getterName', function () {
  if(this.__getterNameCache) { // Cache the getterName (very busy function)
    return this.__getterNameCache
  }
  this.__getterNameCache = this.toPublicName();
  return this.__getterNameCache;
});
Joose.Attribute.meta.addMethod('getStoreAsName', function () {
  return this._name[0] == '_' ? this._name : '_' + this._name
});
//Joose.Attribute.prototype.getStoreAsName = function () {return this._name[0] == '_' ? this._name : '_' + this._name }
