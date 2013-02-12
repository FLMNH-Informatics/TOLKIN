JooseRole('ShiftChecking',{
  has: {
    lastClicked:   { is: 'rw', lazy: true }
  },
  methods: {
    shiftCheck: function(event){
      if (event.target.type == "checkbox"){
        var trgt = event.target
          , trgtContainer = getContainer(trgt)
          , previousCheck = this._lastClicked
          , allChecks = trgtContainer.getElementsBySelector('input:checkbox')
          , checkedChecks = [];

        if (previousCheck != null){
          if (event.shiftKey == true && getContainer(previousCheck) == trgtContainer){
            var lastIndex = allChecks.indexOf(previousCheck)
              , firstIndex = allChecks.indexOf(trgt);
            allChecks.each (function(chk, index){
              if (lastIndex > firstIndex){
                if (index >= firstIndex && index <= lastIndex){
                  checkedChecks.push(toggleChks(chk, trgt.checked));
                }
              }else if (firstIndex > lastIndex){
                if (index >= lastIndex && index <= firstIndex){
                  checkedChecks.push(toggleChks(chk, trgt.checked));
                }}
            })}
        }
        this.setLastClicked(trgt);
        //return array of selected checks
        return checkedChecks.compact();
      }else{return [];} //return empty array in case of array method chaining

      function getContainer (ele){
        var container;
        //important!: to use this anywhere else, you must add a case.
        switch (ele.up().up().localName){
          case "tr":
            container = ele.up().up().up().localName == "tbody" ? ele.up().up().up().up() : ele.up().up().up(); //check for tbody presence
          break;
          case "div":
            container = ele.up().up();
          break;
          case "td":
            container = ele.up(4);
          break;
        }
        return container;
      }

      function toggleChks (chkbx, toggle) {
        if (toggle == 0){
          chkbx.checked = 0;
        }
        else if (toggle == 1){
          chkbx.checked = 1;
        }
        return chkbx;
      }
    }
  }
})