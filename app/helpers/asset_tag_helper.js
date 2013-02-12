Role('AssetTagHelper', {
  methods: {
    imageTag: function (source, options) {
      options || (options = {});
      return(
        "<img "
          +(options['class'] ? "class=\""+options['class']+"\" " : '')
          +"src=\""+(this.params().pathPrefix||'')
          +"/images/"+source+"\" />"
      );
    }
  }
});


