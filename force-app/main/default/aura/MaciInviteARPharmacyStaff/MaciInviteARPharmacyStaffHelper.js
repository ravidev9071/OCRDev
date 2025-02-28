({
	getCurrentPharmacyAffilationInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        var action = component.get("c.getCurrentPharmacyAffilcationList"); 
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
           let resultData = response.getReturnValue();
           
            if(resultData == null){
                this.showToast(component,event,'Current Pharmacy does not have primary AR.','Error');
                $A.get("e.force:closeQuickAction").fire();
            }else{
                var listLength = resultData.length;
                var ArCounts=0;
                var PrimaryArCounts=0;
                
                
                for (var i=0; i < listLength; i++) {
                    if(resultData[i].US_WSREMS__UserType__c  == 'Authorized Representative' && resultData[i].Status__c != 'Inactive'){
                       ArCounts =  ArCounts+1;
                    }
                    
                    if(resultData[i].AR_Category__c == 'Primary'){
                        PrimaryArCounts = PrimaryArCounts+1;
                        component.set("v.primaryARAccountId",resultData[i].US_WSREMS__Pharmacy_User__c);
                        component.set("v.pharmacyAccountRecord.Id",resultData[i].US_WSREMS__Pharmacy_User__c);
                    }
                }
                component.set("v.primaryARCount",PrimaryArCounts);
                 component.set("v.ARCount",ArCounts);
                if(PrimaryArCounts == 0){
                   this.showToast(component,event,'Current Pharmacy does not have primary AR.','Warning'); 
                }else {
                    
                    component.set("v.ShowScreen", true);  
                }
            }
        });
        $A.enqueueAction(action);    
    },
    
    validateARInfo : function(component,event){
			var userType = component.find("SYN_User_Type__c").get("v.value");
            var action = component.get("c.validatePharmacyStaffDupCheck");
            action.setParams({
                fname : component.get("v.oPharmyInfo.US_WSREMS__First_Name__c"),
                lname : component.get("v.oPharmyInfo.US_WSREMS__Last_Name__c"), 
                email : component.get("v.oPharmyInfo.US_WSREMS__Email__c"), 
                programId : component.get("v.accountRecord.US_WSREMS__REMS_Program__c"),
                pharmacyAcct : component.get("v.accountRecord")
            });
           action.setCallback(this, function(result) {
               var state = result.getState();
               if (component.isValid() && state === "SUCCESS"){
                   var duplicateFlag = result.getReturnValue();
                   
                   if(duplicateFlag == true){
                       component.set("v.ShowSpinner",false);
                       this.showToast(component,event,'A duplicate record with these values already exists.','Warning');
                   }else{
						if(userType == 'Authorized Representative' && component.get("v.ARCount") >= 2 ){
							this.showToast(component,event,'Pharmacy has invited the maximum number of Authorized Representatives.','Warning');	
							component.set("v.ShowSpinner",false);
						}else{
							component.set("v.ShowSpinner",true);
							this.createPharmacyPortalUserAccount(component,event);
						}
				   }
               }else{
                   this.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
               }
           });
            $A.enqueueAction(action);    
    },
    
    createPharmacyPortalUserAccount: function(component,event){
        
        var pharmacyParticipantObjInfo = component.get("v.oPharmyInfo");
        var ptype = component.get("v.accountRecord.Pharmacy_Type__c");
        var pharmacyAcct = component.get("v.accountRecord");
        var userAccount = component.get("v.pharmacyAccountRecord");

        var invitationDate = component.find("US_WSREMS__Date__c").get("v.value");
        
        var action = component.get("c.createPharmacyPortalUserArAccount");
        action.setParams({
            pharmacyObj : pharmacyParticipantObjInfo,
            pharmacyType : ptype,
            pharmacyAccount : pharmacyAcct,
            programId: component.get("v.accountRecord.US_WSREMS__REMS_Program__c"),
            userType : component.find("SYN_User_Type__c").get("v.value"),
            authRepAccount : userAccount,
            startDate : invitationDate
        });
        
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
               var recordId = result.getReturnValue();
                
                if(recordId != null){
                    this.showToast(component,event,'Invitation sent successfully.','success'); 
                    $A.get("e.force:closeQuickAction").fire();
                }else {
                   
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