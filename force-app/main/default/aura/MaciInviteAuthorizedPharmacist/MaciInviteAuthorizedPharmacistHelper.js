({  
    getCurrentPharmacistInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        
        var action = component.get("c.getPharmacistInfo"); 
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
           
           component.set('v.authRepAccount', result);
           this.getCurrentPharmacyInfo(component,event);
        });
        $A.enqueueAction(action);    
    },
    
    getCurrentPharmacyInfo : function(component,event){
        var pname = component.get("v.ProgramName");
        var action = component.get("c.getPharmacyInfo"); 
        var userAccount = component.get("v.authRepAccount");
        action.setParams({
            acc : userAccount,
            ProgramName : pname
        });
        action.setCallback(this, function(response) {
           let result = response.getReturnValue();
           
           component.set('v.pharmacy', result);
           this.getAuthorizedRepsInfo(component,event);
        });
        $A.enqueueAction(action);    
    },
	getTitlePicklistValues: function(component, event) {        
        var action = component.get("c.getPharmacyTitle");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var titleMap = [];
                for(var key in result){
                    titleMap.push({key: key, value: result[key]});
                } 
                component.set("v.titleMap", titleMap);
            }
        });
        $A.enqueueAction(action);
	},
    getCredentialsPicklistValues: function(component, event) {        
        var action = component.get("c.getPharmacyCredentails");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                var credentailsMap = [];
                for(var key in result){
                    credentailsMap.push({key: key, value: result[key]});
                } 
                component.set("v.credentialsMap", credentailsMap);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleNextButton: function(component,event){
      
        var action = component.get("c.validatePharmacyStaffDupCheck");
            action.setParams({
                fname : component.get("v.oPharmyInfo.US_WSREMS__First_Name__c"),
                lname : component.get("v.oPharmyInfo.US_WSREMS__Last_Name__c"), 
                email : component.get("v.oPharmyInfo.US_WSREMS__Email__c"), 
                programId : component.get("v.programId"),
                pharmacyAcct : component.get("v.pharmacy")
            });
           action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
               var duplicateFlag = result.getReturnValue();
                
                if(duplicateFlag == true){
                    component.set("v.ShowSpinner",false);
                    this.showToast(component,event,'A duplicate record with these values already exists. Please update information or contact the REMS Coordinating Center at 1-888-572-2934 for assistance.','Error');
                }else{
                  this.createPharmacyPortalUserAccount(component,event);
              	}
            }else{
                this.showToast(component,event,'Something went wrong, please contact system admin.','Warning');
            }
        });
        $A.enqueueAction(action);
    },
    
    createPharmacyPortalUserAccount: function(component,event){
        var programId = component.get("v.programId");
        var usrType = component.get("v.userType");
        component.set("v.oPharmyInfo.US_WSREMS__REMS_Program__c",programId);
        component.set("v.oPharmyInfo.US_WSREMS__Program_Picklist__c",'Macitentan REMS');
        component.set("v.oPharmyInfo.US_WSREMS__Channel__c",'Portal');
        component.set("v.oPharmyInfo.US_WSREMS__Account_Type__c",'Online');
        component.set("v.oPharmyInfo.US_WSREMS__UserType__c",usrType);
        component.set("v.oPharmyInfo.SYN_User_Type__c",usrType);
        component.set("v.oPharmyInfo.SYN_Pharmacy__c",component.get("v.pharmacy.Id"));
        component.set("v.oPharmyInfo.US_WSREMS__Status__c",'Pending');
         
        var pharmacyParticipantObjInfo = component.get("v.oPharmyInfo");
        var ptype = component.get("v.pharmacyType");
        var pharmacyAcct = component.get("v.pharmacy");
        //var usrType = component.get("v.userType");
        var userAccount = component.get("v.authRepAccount");

        
        var action = component.get("c.createPharmacyPortalUserArAccount");
        action.setParams({
            pharmacyObj : pharmacyParticipantObjInfo,
            pharmacyType : ptype,
            pharmacyAccount : pharmacyAcct,
            programId: programId,
            userType : usrType,
            authRepAccount : userAccount,
			startDate : null
        });
        
        action.setCallback(this, function(result) {
            component.set("v.ShowSpinner",false);
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                
               var recordId = result.getReturnValue();
              
                if(recordId != null){
                    this.showToast(component,event,'Invitation sent successfully.','success'); 
                    this.navigateToDashboardPage(component,event);
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
    
    navigateToDashboardPage : function(component, event) {
        //Navigate to navigateToPharmacyLocator Page
        var nav = component.find("navigation");
        var ptype = component.get("v.pharmacyType");
        if(ptype == 'Outpatient'){
            var pageReference = {
                type: "comm__namedPage",
                attributes: {
                    pageName: 'pharmacy-manage-home'
                }
            };
        }else{
            var pageReference = {
                type: "comm__namedPage",
                attributes: {
                    pageName: 'inpatient-manage-pharmacy'
                }
            };
        }
        nav.navigate( pageReference ); 
    },
})