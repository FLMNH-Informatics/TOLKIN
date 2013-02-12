JooseRole('VersionInformation', {
  after: {
    initialize: function () {
      this.checkEditable();
    }
  },
  methods: {
    checkEditable:  function () {
      if (!this.isEditable()){
        var me = this;
        setTimeout(function (){
          me.refresh({
            method: 'get',
            requestHeaders: { Accept: "application/json" },
            onSuccess: function(transport){
              if (transport.responseText){
                var obj = Object.values(transport.responseText.evalJSON()).first();
                me._data = obj;
                me.checkEditable();
             }
            }
          });
        }, 15000);
      }
    },
    markNotEditable:function()  { this._data.timeline.timeline.editable = false; },
    requestPath:    function () { return "/projects/" + params["project_id"] + "/"+ this.meta._name.split('.').first().toLowerCase() + "/matrices/" + this.id(); },
    timeline:       function () { if (this.is('loaded')) return this._data.timeline.timeline; },
    lastVersion:    function () { if (this.is('loaded')) return this._data.versions.last().timeline; },
    versions:       function () { if (this.is('loaded')) return this._data.versions;},
    currentVersion: function () { if (this.is('loaded')) return this.timeline(); },
    copyMatrixLink: function () { if (this.is('loaded')) return '<a id="copy_matrix">make a copy</a>'},
    lastVersionLink:function () { if (this.is('loaded')) return '<a href=' + this.lastVersionUrl() + '>current version</a>'},
    lastVersionUrl: function () { if (this.is('loaded')) return '/projects/' + params['project_id'] + '/'+ this.meta._name.split('.').first().toLowerCase() + '/matrices/' + this.lastVersion().id},
    isLastVersion:  function () { if (this.is('loaded')) return (this.lastVersion().id == this.timeline().id); },
    isEditable:     function () { if (this.is('loaded')) return this._data.timeline.timeline.editable; },
    editable:       function () { return this.isEditable(); },
    wrongVersionMessage: function () { if (this.is('loaded')) {
      return 'Editing can only be done on ' +
        this.lastVersionLink() +
        '. You may ' +
        this.copyMatrixLink() +
        ' if you would like to use this version.' }
    },
    doIfLastVersion: function (fn,page){
      if (this.is('loaded')) {
        if (this.isEditable()){
          if (this.isLastVersion()){
            if (page.iMode()._value == 'edit'){
              fn();
            }else{
              page.notifier().warn('You must be in edit mode to complete this action.')
            }
          }else{
            page.showWrongVersionMessage();
          }
        }else{
          page.notifier().warn('This matrix is still being processed by TOLKIN.  Please wait a few minutes and try again. ')
        }
      }
    },
    doIfNotProcessing: function (fn, page){
      if (this.is('loaded')){
        if (this.isEditable()){
          fn();
        }else{
          page.notifier().warn('This matrix is being processed by TOLKIN in the background. Please try in a few minutes. ')
        }
      }
    }
  }
})