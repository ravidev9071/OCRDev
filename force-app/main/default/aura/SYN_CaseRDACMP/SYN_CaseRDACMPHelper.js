({
	handleSearch : function(component) {
		var AuthorizationNum = component.get("v.AuthNUM")
        var PatientName = component.get("v.PatientName");
        var PatientDOB = component.get("v.PatientDOB");
        var PrescriberName = component.get("v.PrescriberName");  
        var PrescriberDEA = component.get("v.DEA");
        var action = component.get("c.getCaseRDA");
        action.setParams({
            AuthorizationNum:AuthorizationNum,
            PatientName:PatientName,
            PatientDOB:PatientDOB,
            PrescriberName:PrescriberName,
            PrescriberDEA:PrescriberDEA
            
        });
        action.setCallback( this, function( data ) {
            /*var alldt = data.getReturnValue();
            alldt.sort((a,b) => (a.LastName.toUpperCase() > b.LastName.toUpperCase()) ? 1 : ((b.LastName.toUpperCase() > a.LastName.toUpperCase()) ? -1 : 0));
            
            component.set("v.CaseList", alldt);
            this.buildData(component,1);*/
             component.set("v.CaseList", data.getReturnValue());
             this.buildData(component,1);
        });
        $A.enqueueAction( action );
    }, 
    buildData:  function(cmp, pageNo) {
        var callList = cmp.get("v.CaseList");//cmp.get("v.rows");
        //var allData = cmp.get("v.CaseList");
        var noOfCalls = cmp.get("v.noOfCallsToBeShown");
        var callListToBeShown = [];
        for(var i=(pageNo-1)*noOfCalls; i<(pageNo*noOfCalls); i++) {
            if(callList[i]) {
                callListToBeShown.push(callList[i]);
            }
        }
        //callListToBeShown.sort((a,b) => (a.LastName > b.LastName) ? 1 : ((b.LastName > a.LastName) ? -1 : 0));
        //callListToBeShown.sort((a,b) => a.LastName - b.LastName);
        
        cmp.set('v.CaseListToBeShown', callListToBeShown);
        cmp.set('v.CaseList', callList);
        
    },
    getAccess : function(component,event,helper) {
        var action = component.get("c.getPermissionsBasedonAccountStatus");
        action.setParams({
            buttonName:'Mange Pre-Dispense'
           
            
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
        var CaseList = component.get("c.getCaseRDA");
        CaseList.setParams({
            AuthorizationNum:'',
            PatientName:'',
            PatientDOB:'',
            PrescriberName:'',
            DEA:''
            
        });
        CaseList.setCallback(this, function(data) {
            /*var allData = data.getReturnValue();
            allData.sort((a,b) => (a.LastName.toUpperCase() > b.LastName.toUpperCase()) ? 1 : ((b.LastName.toUpperCase() > a.LastName.toUpperCase()) ? -1 : 0));
            component.set("v.CaseList",allData );
           */
             component.set("v.CaseList", data.getReturnValue());
             this.buildData(component,1);
        });
        $A.enqueueAction(CaseList);
	}
})