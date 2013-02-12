String.prototype.singularize = function () {
  if(this.match(/a$/)) {
    return this.sub(/xa$/, 'xon') // taxa -> taxon
  } else if(this.match(/ices$/)) {
    return this.gsub(/ices$/, 'ix') // matrices -> matrix, exclude: sequences -> sequence
  } else if(this.match(/ces$/)) {
    return this.gsub(/ces$/, 'ce'); // sequences -> sequence
  } else if(this.match(/ges$/)) { 
    return this.sub(/ges$/, 'ge') // changes -> change
  } else if(this.match(/ies$/)) {
    return this.sub(/ies$/, 'y')
  } else if(this.match(/[Pp]eople$/)) {
    return this.sub(/ople$/, 'rson');
  } else if(this.match(/les$/)) { // dna_samples -> dna_sample
    return this.sub(/les$/, 'le')
  } else if(this.match(/es$/)) {
    return this.sub(/es$/, '')
  } else if(this.match(/^status$/)) { // status -> status  // WRONG - where is this being used - fix this if possible
    return this
  } else {
    return this.gsub(/s$/, '')
  }
}

String.prototype.pluralize = function () {
  if(this.match(/xon$/)) { // taxon -> taxa
    return this.sub(/xon$/, 'xa')
  } else if(this.match(/x$/)) { // matrix -> matrices
    return this.sub(/x$/, 'ces')
  } else if (this.match(/y$/)) { // bioentry -> bioentries
    return this.sub(/y$/, 'ies')
  } else if(this.match(/h$/)) { // branch -> branches
    return this+'es';
  } else if(this.match(/s$/)) { // don't pluralize s endings by default
    return this;
  } else if(this.match(/[Pp]erson$/)) {
    return this.sub(/rson$/, 'ople');
  } else {
    return this+'s' // otu -> otus
  }
}

String.prototype.camelize = function (capitalize) {
  var camelized = this.replace(/[-_]+(.)?/g, function(match, chr) { // added underscore as possibility
    return chr ? chr.toUpperCase() : '';
  });
  return(capitalize ? camelized.charAt(0).toUpperCase() + camelized.substr(1) : camelized )

}

String.prototype.humanize = function () {
  return this.sub(/_id$/, '').gsub(/_/, ' ').capitalize()
}
