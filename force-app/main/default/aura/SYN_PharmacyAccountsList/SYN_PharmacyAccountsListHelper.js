({
    
   
    
     buildData:  function(cmp, pageNo) {
        var callList = cmp.get("v.rows");
        var noOfCalls = cmp.get("v.noOfCallsToBeShown");
        var callListToBeShown = [];
        for(var i=(pageNo-1)*noOfCalls; i<(pageNo*noOfCalls); i++) {
            if(callList[i]) {
                callListToBeShown.push(callList[i]);
            }
        }
        cmp.set('v.AccountListToBeShown', callListToBeShown);
         
    },
   
    
})