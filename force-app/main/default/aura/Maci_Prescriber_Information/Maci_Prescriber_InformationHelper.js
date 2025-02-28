({  
    
    getProviderDetails: function(component,event,helper){
        var action = component.get("c.getProviderNPIDetails");        
        var providerNpi = component.get("v.newCase.US_WSREMS__NPI__c");
         action.setParams({
             providerNPI : providerNpi
         });
        action.setCallback(this, function(result) {
            var state = result.getState();
             component.set("v.ShowSpinner",false);
           
            if (component.isValid() && state === "SUCCESS"){
                var prescriber = result.getReturnValue();
                
                if(prescriber != null){
                    component.set("v.ShowNPIInfo",true);
                    component.set("v.prescriberNPIObj.firstName",prescriber.FirstName);
                    component.set("v.prescriberNPIObj.middleName",prescriber.MiddleName);
                    component.set("v.prescriberNPIObj.lastName",prescriber.LastName);
                    component.set("v.prescriberNPIObj.addressLine1",prescriber.StreetAddress);
                    component.set("v.prescriberNPIObj.city",prescriber.city);
                    component.set("v.prescriberNPIObj.state",prescriber.State);
                    component.set("v.prescriberNPIObj.zipCode",prescriber.postalCode);
                    component.set("v.prescriberNPIObj.Phone1",prescriber.Phonenumber1);
                     component.set("v.prescriberNPIObj.speciality",prescriber.specialty_1);
                }else{
                    this.showToast(component,event,'We did not find prescriber information based on your input.','Error');
                }
               
            }else if(state === "ERROR"){
                  this.showToast(component,event,'Something Went Wrong','Warning');
            }
        });
        $A.enqueueAction(action);
    },
    
    handleNextButton: function(component,event){
        var prescriberEmail = component.get("v.newCase.Email_address__c");
        var providerNpi = component.get("v.newCase.US_WSREMS__NPI__c");
        var programId = component.get("v.programId");
        var userRole = component.get("v.userrole");
        var providerLname = component.get("v.prescriberNPIObj.lastName");
        var providerPhone = component.get("v.prescriberNPIObj.Phone1");
        var action = component.get("c.validatePortalUserInfo");
         action.setParams({
             email : prescriberEmail,
             npi : providerNpi, 
             role : userRole,
             program : 'Macitentan REMS',
             lname : providerLname,
             phone : providerPhone
         });
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var duplicateFlag = result.getReturnValue();
                
                if(duplicateFlag != 'NotFound'){
                    this.showToast(component,event,duplicateFlag,'Warning');
                }else{
                    
                    var evt = component.getEvent("ShowPrescriberScreens");
                    evt.setParams({
                        "showScreen" : true,
                        "screenName": "PrimaryOffice",
                        "prescriberInfo" : component.get("v.newCase"),
                        "prescriberNPIObj" : component.get("v.prescriberNPIObj"),
                        "ShowNPIInfo" : component.get("v.ShowNPIInfo"),
                    });
                    evt.fire();
                }
            }else{
                this.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : titleType,
                message: errMsg,
                duration:' 5000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
    
    handleRefresh: function(component,event){
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
            "showScreen" : true,
            "screenName": "refreshPrescriberInformation",
        });
        evt.fire();
    },
    
     fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
            "showScreen" : true,
            "screenName": screenName
        }).fire();
    },
 
})