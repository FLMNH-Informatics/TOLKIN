OpenLayers.Format.GeoRSS.prototype.createFeatureFromItem = function(item){
  var geometry=this.createGeometryFromItem(item);
  var title=this.getChildValue(item,"*","title",this.featureTitle);
  var description=this.getChildValue(item,"*","description",this.getChildValue(item,"*","content",this.getChildValue(item,"*","summary",this.featureDescription)));
  var link=this.getChildValue(item,"*","link");
  if(!link){
    try{
      if(this.getElementsByTagNameNS(item,"*","link")[0])
        link=this.getElementsByTagNameNS(item,"*","link")[0].getAttribute("href");
    }catch(e){
      link=null;
    }
  }
var id=this.getChildValue(item,"*","id",null);
  var data={
  "title":title,
  "description":description,
  "link":link
};

var feature=new OpenLayers.Feature.Vector(geometry,data);
  feature.fid=id;
  return feature;
  }
