String.prototype.evalJSON = function evalJSON(sanitize){
  var json=this.unfilterJSON();
  try{
    if(!sanitize||json.isJSON()){
      if(this.length < 1) { return eval('') } // line added to prevent 'Badly formed JSON string' errors
      return eval("("+json+")")
    }
  }catch(e){}
  throw new SyntaxError("Badly formed JSON string: "+this.inspect())
}