({
    handleNextButton: function(component, event, helper) {
        var OfficeContactEmail = component.get("v.pCase.Email_address__c");
        var programId = component.get("v.programId");
        var userRole = component.get("v.userrole");
        var OfficeContactLname = component.get("v.primaryOtherInfoObj.lastName");
        var OfficeContactfname = component.get("v.primaryOtherInfoObj.firstName");
        var OfficeContactPhone = component.get("v.pCase.US_WSREMS__Phone__c");
        var speciality =  component.get("v.pCase.Specialty__c");
       component.set("v.pCase.Phone_Secondary_Office__c",component.get("v.pCase.US_WSREMS__REMS_Office_Contact_Phone__c"));
        if(OfficeContactfname != undefined && OfficeContactfname != ''  &&
            OfficeContactLname != undefined && OfficeContactLname != '' &&
            OfficeContactEmail != undefined && OfficeContactEmail != ''
        ) {
            var action = component.get("c.validateOfficeContactDupChecker");
                action.setParams({
                    email: OfficeContactEmail,
                    role: userRole,
                    program: 'Macitentan REMS',
                    lname: OfficeContactLname  ,
                    fname: OfficeContactfname  ,
                    phone : OfficeContactPhone

                });
            action.setCallback(this, function(result) {
                component.set("v.ShowSpinner", false);
                var state = result.getState();
                
                if (component.isValid() && state === "SUCCESS") {
                    var duplicateFlag = result.getReturnValue();
                  
                    if (duplicateFlag.duplicateMessage  === 'LastNameAndEmailFound') {
                        // helper.showConfirmationModal(component, event, helper);
                        component.set("v.isModalOpen",true);
                        component.set("v.primaryOtherInfoObj.Id",duplicateFlag.officeContact.Id);
                    }
                    if (duplicateFlag.duplicateMessage === 'EmailFound') {
                        component.set("v.primaryOtherInfoObj.Id",'');
                        this.showToast(component,event,'Office Contact email address already exists for another account, please use a unique email address, remove the email address, or contact the REMS Coordinating Center at 1-888-572-2934.','Error');
                    } else if(duplicateFlag.duplicateMessage === 'NotFound') {
                        component.set("v.primaryOtherInfoObj.Id",'');
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
                            "showScreen": true,
            "screenName": "SecondaryOffice",
                            "pCase": component.get("v.pCase"),
                            "primaryOtherInfoObj": component.get("v.primaryOtherInfoObj")
                        });
                        evt.fire();
                    }  
                } else {
                    component.set("v.primaryOtherInfoObj.Id",'');
                    alert('Something went wrong, please contact system admin.');
                }
            });
            $A.enqueueAction(action);
        } else {
            var evt = component.getEvent("ShowPrescriberScreens");
                evt.setParams({
                    "showScreen": true,
                    "screenName": "SecondaryOffice",
                    "pCase": component.get("v.pCase"),
                    "primaryOtherInfoObj": component.get("v.primaryOtherInfoObj")
        });
        evt.fire();
        }
        
    },
    
    
    
    fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
            "showScreen" : true,
            "screenName": screenName
        }).fire();
    },
    
    handleRefresh: function(component,event){
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
            "showScreen" : true,
            "screenName": "refreshPrimaryOffice",
        });
        evt.fire();
    },
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                 message: errMsg,
                duration:' 10000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
    
    getstatePicklist: function(component, event) {        
        var action = component.get("c.getStates");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var stateMap = [];
                for(var key in result){
                    stateMap.push({key: key, value: result[key]});
                } 
                component.set("v.stateMap", stateMap);
            }
        });
        $A.enqueueAction(action);
    },

})