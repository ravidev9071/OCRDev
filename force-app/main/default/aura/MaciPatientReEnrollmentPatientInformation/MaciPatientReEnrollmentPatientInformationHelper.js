({
	handleNextButton: function(component,event){
        

        var patientFname = component.get("v.newCase.US_WSREMS__First_Name__c");
        var patientLname = component.get("v.newCase.US_WSREMS__Last_Name__c");
        var patientZip = component.get("v.newCase.US_WSREMS__REMS_Zip_Code__c");
        var patientDob = component.get("v.newCase.US_WSREMS__DOB__c");
        var action = component.get("c.validatePatientDupCheck");
            action.setParams({
             fname : patientFname,
             lname : patientLname, 
             zip : patientZip,
             program : 'Macitentan REMS',
             dob : patientDob
         });
           action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
               var duplicateFlag = result.getReturnValue();
                
                
                   var evt = component.getEvent("ShowPatientEnrollmentScreens");
                    evt.setParams({
                   "screenName": "ShowAlternateContactInformationScreen",
                   "newCase" : component.get("v.newCase"),
                   "isPatientMinor" : component.get("v.isPatientMinor"),
                   "confirmEmail" : component.get("v.confirmEmail")
                  });
                 evt.fire();
              
            }else{
                this.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
            }
        });
        $A.enqueueAction(action);
    },
    
    handleRefresh: function(component,event){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": "refreshShowPatientInformationScreen",
        });
        evt.fire();
    },
    
     fireEvent: function(component,event,screenName){
        var evt = component.getEvent("ShowPatientEnrollmentScreens");
        evt.setParams({
            "screenName": screenName
        }).fire();
    },
    
     showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : titleType,
                message: errMsg,
                duration:'10000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
    
     calculate_age : function(component,event,dob) {
         var diff_ms = Date.now() - dob.getTime();
         var age_dt = new Date(diff_ms); 
         return Math.abs(age_dt.getUTCFullYear() - 1970);
    },
    
    
})