({
  
    handleRecordChanged: function(component, event, helper) {
        component.set("v.recordtypeid", $A.get("$Label.c.Pharmacy_Participant_Account_Case_Record_Type_Id")); 
        component.set("v.ShowSpinner", true); 
        var eventParams = event.getParams();
        if(eventParams.changeType == "LOADED"){
            if(component.get("v.accountRecord.US_WSREMS__Status__c") != 'Certified'){
                component.set("v.ShowSpinner", false); 
              helper.showToast(component,event,'Pharmacy is not certified','Error');
              $A.get("e.force:closeQuickAction").fire();
            }else{
                 component.set("v.ShowSpinner", false);
                helper.getCurrentPharmacyAffilationInfo(component, event);
            }
        }
        
    },
   
    handleOnSubmit : function(component, event, helper) {
      
        var userType = component.find("SYN_User_Type__c").get("v.value");
        var arCategory = component.find("AR_Category__c").get("v.value");
        var firstName = component.find("US_WSREMS__First_Name__c").get("v.value");
        var lastName = component.find("US_WSREMS__Last_Name__c").get("v.value");
        var credentials = component.find("Credentials__c").get("v.value");
        var title = component.find("Title__c").get("v.value");
        var email = component.find("US_WSREMS__Email__c").get("v.value");
        var program = component.find("US_WSREMS__Program_Picklist__c").get("v.value");
        var invitationDate = component.find("US_WSREMS__Date__c").get("v.value");
        
        
        component.set("v.oPharmyInfo.US_WSREMS__REMS_Program__c",component.get("v.accountRecord.US_WSREMS__REMS_Program__c"));
        component.set("v.oPharmyInfo.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
        component.set("v.oPharmyInfo.US_WSREMS__Channel__c",'Portal');
        component.set("v.oPharmyInfo.US_WSREMS__Account_Type__c",'Online');
        component.set("v.oPharmyInfo.US_WSREMS__UserType__c",userType);
        component.set("v.oPharmyInfo.SYN_User_Type__c",userType);
        component.set("v.oPharmyInfo.SYN_Pharmacy__c",component.get("v.recordId"));
        component.set("v.oPharmyInfo.US_WSREMS__Status__c",'Pending');
        component.set("v.oPharmyInfo.US_WSREMS__First_Name__c",firstName);
        component.set("v.oPharmyInfo.US_WSREMS__Last_Name__c",lastName);
        
        if(component.find("Title__c").get("v.value")== 'Other title'){
            component.set("v.oPharmyInfo.Other_Title__c",component.find("Other_Title__c").get("v.value"));
        }
        
        if(component.find("Credentials__c").get("v.value") == 'Other'){
            component.set("v.oPharmyInfo.Other_Credential__c", component.find("Other_Credential__c").get("v.value"));
        }
        
        component.set("v.oPharmyInfo.Credentials__c",credentials);
        component.set("v.oPharmyInfo.Title__c",title);
        component.set("v.oPharmyInfo.US_WSREMS__Email__c",email);
        
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        console.log('----userType----'+userType);
                console.log('----arCategory----'+arCategory);

                console.log('----invitationDate----'+invitationDate);

        if(userType.includes(";")){
            helper.showToast(component,event,'User type should not select more than one','Warning');
            event.preventDefault();
        }else if(userType == 'Pharmacist'){
             helper.showToast(component,event,'Current user type is not applicable','Warning');
             event.preventDefault();
        }else if(arCategory == 'Primary'){
             helper.showToast(component,event,'You cannot invite Primary AR','Warning');	
             event.preventDefault();
        }else if(userType == 'Pharmacy Staff' && (arCategory == 'Primary' || arCategory == 'Secondary')){
             helper.showToast(component,event,'AR category is not applicable to current user type.','Warning');	
             event.preventDefault();
        }else if(invitationDate != null){
             console.log('----I am in ----');
            component.set("v.ShowSpinner", true);
            var action = component.get("c.checkInvitatoDate");
            action.setParams({
                invitationDate : invitationDate
            });
            action.setCallback(this, function(result) {
                var state = result.getState();
                if (component.isValid() && state === "SUCCESS"){
                    var isValidDate = result.getReturnValue();
                    
                    if(isValidDate == true){
                        helper.validateARInfo(component, event);
                    }else{
                        component.set("v.ShowSpinner",false);
                        helper.showToast(component,event,'The Invitation Date should be future date.','Warning');   
                    }
                }else{
                    helper.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
                }
            });
            $A.enqueueAction(action);
             	
        }else{
            event.preventDefault();
            console.log('----I am in 1----');
            component.set("v.ShowSpinner", true);
            helper.validateARInfo(component, event);
        }

    },

    checkCredentials : function(component, event, helper) {
        var credentials = component.find("Credentials__c").get("v.value");
        if(credentials == 'Other'){
            component.set("v.showOtherCredentialsField", true);
        }else{
            component.set("v.showOtherCredentialsField", false);
        }
    },
    
    
    checkTitleCredentials : function(component, event, helper) {
        var title = component.find("Title__c").get("v.value");
        if(title == 'Other title'){
            component.set("v.showOtherTitleField", true);
        }else{
            component.set("v.showOtherTitleField", false);
        }
    },
    
    handleOnLoad : function(component, event, helper) {
        component.set("v.recordtypeid", $A.get("$Label.c.Pharmacy_Participant_Account_Case_Record_Type_Id")); 
        
    },
   
    handleOnError : function(component, event, helper) {
        
    },
})