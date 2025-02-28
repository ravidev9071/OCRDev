({
    handleNextButton: function(component, event, helper) {
        var OfficeContactEmail = component.get("v.sCase.Email_Secondary_Office__c");
        var programId = component.get("v.programId");
        var userRole = component.get("v.userrole");
        var OfficeContactLname = component.get("v.secondaryOtherInfoObj.lastName");
        var OfficeContactfname = component.get("v.secondaryOtherInfoObj.firstName");
        var OfficeContactPhone = component.get("v.sCase.Phone_Secondary_Office__c");
        
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
                        component.set("v.isModalOpen",true);
                        component.set("v.secondaryOtherInfoObj.Id",duplicateFlag.officeContact.Id);
                    }
                    if (duplicateFlag.duplicateMessage === 'EmailFound') {
                        component.set("v.secondaryOtherInfoObj.Id",'');
                        this.showToast(component,event,'Office Contact email address already exists for another account, please use a unique email address, remove the email address, or contact the REMS Coordinating Center at 1-888-572-2934.','Error');
                        
                    } else if(duplicateFlag.duplicateMessage === 'NotFound') {
                        component.set("v.secondaryOtherInfoObj.Id",'');
                        var evt = component.getEvent("ShowPrescriberScreens");
                        evt.setParams({
                            "showScreen" : true,
                            "screenName": "Password",
                            "sCase" : component.get("v.sCase"),
                            "secondaryOtherInfoObj" : component.get("v.secondaryOtherInfoObj")
                        });
                        evt.fire();
                    }  
                } else {
                    component.set("v.secondaryOtherInfoObj.Id",'');
                    alert('Something went wrong, please contact system admin.');
                }
            });
            $A.enqueueAction(action);
        } else {
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
            "showScreen" : true,
            "screenName": "Password",
            "sCase" : component.get("v.sCase"),
            "secondaryOtherInfoObj" : component.get("v.secondaryOtherInfoObj")
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
            "screenName": "refreshSecondaryOffice",
        });
        evt.fire();
    },
     showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: errMsg,
                duration:' 5000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
})