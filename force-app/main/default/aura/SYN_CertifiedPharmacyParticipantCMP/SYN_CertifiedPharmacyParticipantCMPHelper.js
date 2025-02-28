({
    handleSearch: function( component ) {
        var FirstName = component.get("v.FName");
        var LastName = component.get("v.LName");
        var DEA = component.get("v.DEASearch");
        var Phone = component.get("v.PhoneSearch");                                          
        var action = component.get("c.getCertifiedAccounts");
        action.setParams({
            FirstName:FirstName,
            LastName:LastName,
            DEA:DEA,
            Phone:Phone
            
        });
        action.setCallback( this, function( data ) {
            var alldt = data.getReturnValue();
            alldt.sort((a,b) => (a.LastName.toUpperCase() > b.LastName.toUpperCase()) ? 1 : ((b.LastName.toUpperCase() > a.LastName.toUpperCase()) ? -1 : 0));
            
            component.set("v.accountList", alldt);
            this.buildData(component,1);
            
        });
        $A.enqueueAction( action );
    }, 
    buildData:  function(cmp, pageNo) {
        var callList = cmp.get("v.accountList");//cmp.get("v.rows");
        //var allData = cmp.get("v.accountList");
        var noOfCalls = cmp.get("v.noOfCallsToBeShown");
        var callListToBeShown = [];
        for(var i=(pageNo-1)*noOfCalls; i<(pageNo*noOfCalls); i++) {
            if(callList[i]) {
                callListToBeShown.push(callList[i]);
            }
        }
        //callListToBeShown.sort((a,b) => (a.LastName > b.LastName) ? 1 : ((b.LastName > a.LastName) ? -1 : 0));
        //callListToBeShown.sort((a,b) => a.LastName - b.LastName);
        
        cmp.set('v.AccountListToBeShown', callListToBeShown);
        cmp.set('v.accountList', callList);
        
    },
    getAccess : function(component,event,helper) {
        var action = component.get("c.getPermissionsBasedonAccountStatus");
        action.setParams({
            buttonName:'Find a Prescriber'
           
            
        });
        action.setCallback(this, function(response) {
           component.set("v.haveAccess",response.getReturnValue().status);
           component.set("v.errorMessage",response.getReturnValue().buttonerrorMessage);
            if(response.getReturnValue().status){
                helper.init(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    init : function(component,event,helper) {
        var accountList = component.get("c.getCertifiedAccounts");
        accountList.setParams({
            FirstName:'',
            LastName:'',
            DEA:'',
            Phone:''
            
        });
        accountList.setCallback(this, function(data) {
            var allData = data.getReturnValue();
            allData.sort((a,b) => (a.LastName.toUpperCase() > b.LastName.toUpperCase()) ? 1 : ((b.LastName.toUpperCase() > a.LastName.toUpperCase()) ? -1 : 0));
            component.set("v.accountList",allData );
            this.buildData(component,1);
        });
        $A.enqueueAction(accountList);
    }
})