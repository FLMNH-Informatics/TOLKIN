Role('FormHelper', {
  methods: {
    textField: function (object, method, options) {
      options || (options = {});
      return(
        '<input type="text" name="'
          +object.shortName()
          +'['+method+']" value="'
          +(object.attributes()[method]||'')
          +'" style="width:'
          +(options.width||200)
          +'px" />'
      );
    }
  }
});