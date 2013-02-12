JooseModule('SyncRecords', function () { });

(SyncRecords.OptionsHash = function (options) {
  Object.extend(this, options)
}).prototype = {
  clearConditions: function (options) {
    if (options.recursive) {
      // TODO: handle recursive condition clearing
    }
    delete this.conditions
    return this
  },

  toQueryParams: function () {
    return this._nodeToParams(this, {}, null)
  },
  _nodeToParams: function (node, out, prefix) {
    if (!(node.select===undefined)) {
      out[prefix ? prefix+'[select][]' : 'select[]'] = node.select
    }
    if (!(node.order===undefined)) {
      out[prefix ? prefix+'[order][]' : 'order[]'] = node.order
    }
    if (!(node.conditions===undefined)) {
      out[prefix ? prefix+'[conditions]' : 'conditions'] = node.conditions.toString()
    }
    if (!(node.limit===undefined)) {
      out[prefix ? prefix+'[limit]' : 'limit'] = node.limit
    }
    if(!(node.offset===undefined)) {
      out[prefix ? prefix+'[offset]' : 'offset'] = node.offset
    }
    this._joinToParams(node.joins, out, prefix ? prefix+'[joins]' : 'joins')
    if(!(node.include===undefined)) {
      for(var key in node.include) {
        this._nodeToParams(node.include[key], out, prefix ? prefix+'[include]['+key+']' : 'include['+key+']')
      }
    }
    return out
  },
  _joinToParams: function (jNode, out, prefix) {
    if(Object.isString(jNode)) {
      out[prefix+'[]'] = jNode
    } else {
      if(Object.isArray(jNode)) {
        jNode.each(function(j) { this._joinToParams(j, out, prefix) }, this)
      } else {
        for(var k in jNode) {
          this._joinToParams(jNode[k], out, prefix+'['+k+']')
        }
      }
    }
    
  }
}