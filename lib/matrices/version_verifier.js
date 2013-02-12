JooseRole('VersionVerifier', {
  methods: {
    matrixInfo: function () {return this.records().get('matrixInfo')},
    showWrongVersionMessage: function () {this.notifier().warning(this.matrixInfo().wrongVersionMessage());}
  }
})