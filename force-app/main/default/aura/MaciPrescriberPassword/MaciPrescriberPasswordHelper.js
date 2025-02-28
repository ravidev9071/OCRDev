({ 
    
    
    handleNextButton: function(component,event){
        var programId = component.get("v.programId");
        component.set("v.prescriberInfo.US_WSREMS__First_Name__c",component.get("v.prescriberNPIObj.firstName"));
        component.set("v.prescriberInfo.US_WSREMS__Middle_Name__c",component.get("v.prescriberNPIObj.middleName"));
        component.set("v.prescriberInfo.US_WSREMS__Last_Name__c",component.get("v.prescriberNPIObj.lastName"));
        component.set("v.prescriberInfo.US_WSREMS__REMS_Program__c",programId);
        component.set("v.prescriberInfo.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
        component.set("v.prescriberInfo.US_WSREMS__Channel__c",'Portal');
		
		// Primary office Fields
        component.set("v.prescriberInfo.Office_Practice_Clinic_Name__c",component.get("v.pCase.Office_Practice_Clinic_Name__c"));
        component.set("v.prescriberInfo.Specialty__c",component.get("v.pCase.Specialty__c"));
        component.set("v.prescriberInfo.Affiliated_hospital__c",component.get("v.pCase.Affiliated_hospital__c"));
        component.set("v.prescriberInfo.US_WSREMS__Address_Line_1__c",component.get("v.pCase.US_WSREMS__Address_Line_1__c"));
        component.set("v.prescriberInfo.US_WSREMS__City__c",component.get("v.pCase.US_WSREMS__City__c"));
        component.set("v.prescriberInfo.US_WSREMS__REMS_Zip_Code__c",component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c"));
        component.set("v.prescriberInfo.US_WSREMS__State__c",component.get("v.pCase.US_WSREMS__State__c"));
        component.set("v.prescriberInfo.US_WSREMS__Email__c",component.get("v.pCase.US_WSREMS__Email__c"));
        component.set("v.prescriberInfo.US_WSREMS__Phone__c",component.get("v.pCase.US_WSREMS__Phone__c"));
        component.set("v.prescriberInfo.US_WSREMS__REMS_Office_Contact_Phone__c",component.get("v.pCase.US_WSREMS__REMS_Office_Contact_Phone__c"));
        component.set("v.prescriberInfo.US_WSREMS__Fax__c",component.get("v.pCase.US_WSREMS__Fax__c"));
        component.set("v.prescriberInfo.US_WSREMS__Preferred_Contact_Method__c",component.get("v.pCase.US_WSREMS__Preferred_Contact_Method__c"));
		component.set("v.prescriberInfo.US_WSREMS__REMS_Ext__c",component.get("v.pCase.US_WSREMS__REMS_Ext__c"));
        component.set("v.prescriberInfo.US_WSREMS__Address_Line_2__c",component.get("v.pCase.US_WSREMS__Address_Line_2__c"));
        
        // Secondary Office Fields
        component.set("v.prescriberInfo.Office_Practice_Clinic_Name1__c",component.get("v.sCase.Office_Practice_Clinic_Name1__c"));
        component.set("v.prescriberInfo.Specialty_Secondary_Office__c",component.get("v.sCase.Specialty_Secondary_Office__c"));
        component.set("v.prescriberInfo.Affiliated_hospital_Secondary_Office__c",component.get("v.sCase.Affiliated_hospital_Secondary_Office__c"));
        component.set("v.prescriberInfo.Address_1_Secondary_Office__c",component.get("v.sCase.Address_1_Secondary_Office__c"));
        component.set("v.prescriberInfo.City_Secondary_Office__c",component.get("v.sCase.City_Secondary_Office__c"));
        component.set("v.prescriberInfo.SYN_Zip_Code__c",component.get("v.sCase.SYN_Zip_Code__c"));
        component.set("v.prescriberInfo.State_Secondary_Office__c",component.get("v.sCase.State_Secondary_Office__c"));
        component.set("v.prescriberInfo.Email_Secondary_Office__c",component.get("v.sCase.Email_Secondary_Office__c"));
        component.set("v.prescriberInfo.Phone_Secondary_Office__c",component.get("v.sCase.office_contact_phone_Secondary_Office__c"));
        component.set("v.prescriberInfo.office_contact_phone_Secondary_Office__c",component.get("v.sCase.Phone_Secondary_Office__c"));
        component.set("v.prescriberInfo.Fax_Secondary_Office__c",component.get("v.sCase.Fax_Secondary_Office__c"));
        component.set("v.prescriberInfo.Preferred_Contact_Method_Secondary_Offic__c",component.get("v.sCase.Preferred_Contact_Method_Secondary_Offic__c"));
		component.set("v.prescriberInfo.Ext_Secondary_Office__c",component.get("v.sCase.Ext_Secondary_Office__c"));
        component.set("v.prescriberInfo.Address_2_Secondary_Office__c",component.get("v.sCase.Address_2_Secondary_Office__c"));
        
		
		
        
        var primaryOffContactFirstname = component.get("v.primaryOtherInfoObj.firstName");
        var primaryOffContactLastname = component.get("v.primaryOtherInfoObj.lastName");
         
        component.set("v.prescriberInfo.Office_contact_name_Primary_Office__c",primaryOffContactFirstname+' '+primaryOffContactLastname);
       	var secondaryOffContactFirstname = component.get("v.secondaryOtherInfoObj.firstName"); 
        var secondaryOffContactLastname = component.get("v.secondaryOtherInfoObj.lastName");
        component.set("v.prescriberInfo.Office_contact_name_Secondary_Office__c",secondaryOffContactFirstname+' '+secondaryOffContactLastname);
        
        if(component.get("v.prescriberInfo.Alternate_Contact_Name__c") != undefined){
           component.set("v.prescriberInfo.Alternate_Contact__c","Yes"); 
        }
        
        var prescriberObjInfo = component.get("v.prescriberInfo");
        var action = component.get("c.checkPrescriberAccount");
        action.setParams({
            prescriberObj : prescriberObjInfo
        });
        
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
               var accountId = result.getReturnValue();
                
                if(accountId == null){
                   this.insertPrescriberAccount(component,event); 
                }else if(accountId != null){ 
                   component.set("v.prescriberAccountId",accountId);
                     this.createPortalUser(component,event);
                }else{
                   console.log('--Error----');
                }
            }else{
                 component.set("v.ShowSpinner",false);
            }
        });
        $A.enqueueAction(action);  
    },
                           
   
       
   insertPrescriberAccount: function(component,event){
       var prescriberObjInfo = component.get("v.prescriberInfo");
       var action = component.get("c.insertPrescriberAccount");
        var primaryAccountInfo = component.get("v.primaryOtherInfoObj");
        var primaryCaseInfo = component.get("v.pCase");
        var secondaryAccountInfo = component.get("v.secondaryOtherInfoObj");
        var secondaryCaseRecordInfo = component.get("v.sCase");
      
       action.setParams({
            prescriberObj : prescriberObjInfo,
            primaryAccount : primaryAccountInfo,
            primaryCase : primaryCaseInfo,
            secondaryAccount : secondaryAccountInfo,
            secondaryCaseRecord : secondaryCaseRecordInfo
       });
       action.setCallback(this, function(result) {
           var state = result.getState();
           if (component.isValid() && state === "SUCCESS"){
              
              component.set("v.prescriberAccountId",result.getReturnValue());
              this.createPortalUser(component,event);
           }else{
               component.set("v.ShowSpinner",false);
           }
       });
       $A.enqueueAction(action);  
   },
       
   createPortalUser: function(component,event){
    component.set("v.ShowSpinner",false);
       var prescriberObjInfo = component.get("v.prescriberInfo");
       var accId = component.get("v.prescriberAccountId");
       var profileId = component.get("v.profileId");
       var role = component.get("v.userrole");
       var pwd = component.get("v.password");
       var twoFASelection = component.get("v.value2FA");
       var action = component.get("c.createPrescriberPortalUser");   
       action.setParams({
           accountId : accId,
           prescriberObj : prescriberObjInfo,
           profileId : profileId,
           role : role,
           password :pwd,
           twoFASelection : twoFASelection
       });
       action.setCallback(this, function(result) {
           var state = result.getState();
           if (component.isValid() && state === "SUCCESS"){
               var userId = result.getReturnValue();
               
               if(userId != null){
                   var evt = component.getEvent("ShowPrescriberScreens");
                   evt.setParams({
                       "showScreen" : true,
                       "screenName": "maciEmail",
                       "portalUserId" : userId
                   });
                   evt.fire();
               }
           }else{
               component.set("v.ShowSpinner",false);
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