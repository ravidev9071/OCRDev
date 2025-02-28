({
	 handleNextButton: function(component,event){
        var programId = component.get("v.programId");
        var pharmacyType = component.get("v.pharmacyType");
         component.set("v.oPharmyInfo.US_WSREMS__REMS_Program__c",programId);
         component.set("v.oPharmyInfo.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
         component.set("v.oPharmyInfo.US_WSREMS__Channel__c",'Portal');
         component.set("v.oPharmyInfo.US_WSREMS__Account_Type__c",'Online');
         component.set("v.oPharmyInfo.US_WSREMS__UserType__c",'Authorized Representative');
         component.set("v.oPharmyInfo.SYN_User_Type__c",'Authorized Representative');
         component.set("v.oPharmyInfo.AR_Category__c",'Primary');
         
        var pharmacyParticipantObjInfo = component.get("v.oPharmyInfo");
        var profileId = component.get("v.profileId");
        var role = component.get("v.userrole");
        var pwd = component.get("v.password");
        var twoFASelection = component.get("v.value2FA");
        
        var action = component.get("c.createPharmacyPortalUserAccount");
        action.setParams({
            pharmacyObj : pharmacyParticipantObjInfo,
            profileId : profileId,
            role : role,
            password :pwd,
            twoFASelection : twoFASelection 
        });
        
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
               var userId = result.getReturnValue();
                
                if(userId != null){
                    if(pharmacyType == 'Inpatient Pharmacy'){
                        var evt = component.getEvent("ShowInPatinetScreens");
                        evt.setParams({
                            "screenName": "PasswordConfirm",
                            "portalUserId" : userId
                        });
                        evt.fire();
                        
                    }else{
                        var evt = component.getEvent("ShowOutPatinetScreens");
                        evt.setParams({
                            "screenName": "PasswordConfirm",
                            "portalUserId" : userId
                        });
                        evt.fire();
                    }
                    
                }else {
                   console.log('--Error----');
                }
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
})