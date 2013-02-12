JooseModule('TOLJS', function () {
  JooseClass('Path', {
    has: {
      vars: { is: 'ro', init: function () { return {} }},
      action: { is: 'ro', init: null }
    },
    methods: {
      initialize: function (pathname) {
        var regexes = [
          [ /^\/?(\w+)\/([\d\-]+)\/?/, this.extractId ],
          [ /^\/?\w+\/(\w+)\/?/      , this.extractAction ],
          [ /^\/?(\w+)\/?/           , this.setActionIndex ]
        ]
        while(!pathname.empty()) {
          var matchArray = regexes.detect(function (regex) { return pathname.match(regex[0]) }, this);
          if(matchArray) {
            pathname = matchArray[1].bind(this)(pathname, matchArray[0]);
          } else {
            if(!this.action()) { this._action = 'show' }
            break;
          }
        }
      },
      extractId: function (pathname, regex) {
        var match = pathname.match(regex);
        var pluralName = match[1];
        var id = match[2];
        var name = pluralName.singularize();
        this.vars()[name + '_id'] = id;
        return pathname.sub(regex, '');
        
      },
      extractAction: function (pathname, regex) {
        var match = pathname.match(regex);
        this._action = match[1];
        return pathname.sub(regex, '');
        
      },
      setActionIndex: function (pathname, regex) {
        this._action = 'index';
        return pathname.sub(regex, '');
      }
    }
  })
});