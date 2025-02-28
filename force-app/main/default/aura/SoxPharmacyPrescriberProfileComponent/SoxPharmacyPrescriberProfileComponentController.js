({
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.recordId",$A.get("$SObjectType.CurrentUser.Id"));
        const urlString = window.location.pathname;
        const baseURL = urlString.substring(0, urlString.indexOf("/s")).slice(1);
        component.set("v.communityName",baseURL);
        var recTypeName = '';
        if(baseURL === 'Pharmacyportal') {
            recTypeName ='Pharmacy_Participant';
        } else {
            recTypeName ='Prescriber';
        }
        var action = component.get("c.getRecordTypeId");
        action.setParams({
            "RecTypeName" : recTypeName
        });
        action.setCallback(this,function(resp){
            var state = resp.getState();
            if(state === 'SUCCESS') {
                component.set("v.recTypeId",resp.getReturnValue());
            }
        })
        
        $A.enqueueAction(action);
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        debugger;
        if(eventParams.changeType === "LOADED") {
            console.log('fields: ' + JSON.stringify(event.getParam('fields')));
            let fields = event.getParam( 'fields');
            component.set("v.selectedValue",fields.ShippingState);
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted and removed from the cache
        } else if(eventParams.changeType === "ERROR") {
            alert('Error');
        } else if(eventParams.changeType === "CHANGED") {
            alert('Changed');
        }
    },
    updatePersonAccountrec : function(component, event, helper) {
        // component.set("v.showSpinner", true);
        if(component.get("v.isChangedValue") || component.get("v.isEmailChangedValue")  ){
            helper.saveLogic(component,event,helper);
        }else{
            //alert('There is no change');
            // component.set("v.isChangedValue",false); 
        }
        
        
        // }},
    },
    openModel : function(component,event,helper) {
        component.set("v.isEdit",true);
    },
    closeModel : function(component,event,helper) {
        component.set("v.isEdit",false);
    },
    checkAnyChange : function(component,event,helper) {
        //alert('Hi');
        component.set("v.isChangedValue",true);
        
    },
    checkEmailChanged : function(component,event,helper) {
        component.set("v.isEmailChangedValue",true);
    }
})