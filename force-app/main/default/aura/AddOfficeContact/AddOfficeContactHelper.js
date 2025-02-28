({
    validateFields: function(component) {
        let firstName = component.find("firstName").get("v.value");
        let lastName = component.find("lastName").get("v.value");
        let email = component.find("email").get("v.value");

        if (firstName && lastName && email) {
            component.set("v.isSearchDisabled", false);
        } else {
            component.set("v.isSearchDisabled", true);
        }
    },
    
    handleNewSearchHelper : function(component) {
        
        
        component.set("v.displaySpinner", true);
        
        component.set("v.displayContactCreation", false);
        component.set("v.isSearchDisabled", false);
        component.set("v.isFieldDisabled", false);
        component.set("v.errorMessage", null);
        component.set("v.displayExistingContact",false);
        component.set("v.isSubmitDisabled",true);
        
        component.find("firstName").set("v.value",'');
        component.find("lastName").set("v.value",'');
        component.find("email").set("v.value",'');
        
        component.set("v.displaySpinner", false);
        component.set("v.isSearchDisabled", true);
    },
    
    handleContactSubmitHelper : function(component) {
        component.set("v.displaySpinner", true);
        let action = component.get("c.createOfficeContact");
        const phonePattern = /^\d{10}$/;
          if(!component.find("create-phone").get("v.value") ) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Missing Phone",
                "message": "Please Enter phone number to continue"
            });
            toastEvent.fire();
            component.set("v.displaySpinner", false);
            return;
        }
        
        if(component.find("create-phone").get("v.value").length != 10 
            || !phonePattern.test(component.find("create-phone").get("v.value"))) {
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Missing Phone",
                "message": "Please Enter a valid 10 digit mobile number"
            });
            
            component.set("v.displaySpinner", false);
            toastEvent.fire();
            return;
        }
        
        action.setParams({
            firstName: component.get("v.firstName"),
            lastName: component.get("v.lastName"),
            email: component.get("v.email"),
            phone : component.find("create-phone").get("v.value")
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }else {
                console.log('error',response.getError());
            }
            component.set("v.displaySpinner", false);
        });    
        $A.enqueueAction(action);
        
    },

    searchAccounts: function(component) {
        component.set("v.displaySpinner", true);
        let firstName = component.find("firstName").get("v.value");
        let lastName = component.find("lastName").get("v.value");
        let email = component.find("email").get("v.value");
        component.set('v.mycolumns', [
            {label: 'FIRST NAME', fieldName: 'FirstName', type: 'text'},
            {label: 'LAST NAME', fieldName: 'LastName', type: 'text'},
            {label: 'EMAIL', fieldName: 'US_WSREMS__Email__c', type: 'email'},
            {label: 'PHONE', fieldName: 'Phone', type: 'Phone '}
        ]);
        let action = component.get("c.searchForAccounts");
        action.setParams({
            firstName: firstName,
            lastName: lastName,
            email: email
        });
        component.set("v.firstName", firstName);
        component.set("v.lastName", lastName);
        component.set("v.email", email);
        
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.acctList", result);
                component.set("v.errorMessage", null);
                component.set("v.isAccount", true);
                component.set("v.displayWarning",false);
                component.set("v.displayError",false);
                component.set("v.displaySuccess",false);
                
                
                
                if(result.status == 'No results match your search criteria. Add new Office Contact information in blank fields below') {
                    component.set("v.displayContactCreation",true);
                    component.set("v.isSearchDisabled", true);
                    component.set("v.isSubmitDisabled", false);
                    component.set("v.isFieldDisabled", true);   
                    component.set("v.errorMessage", result.status);
                    component.set("v.warningTheme", 'slds-box slds-theme_warning slds-m-top_medium');
                    component.set("v.displayWarning",true);
                    
                } else if (result.status == 'Multiple Accounts with this email address and last name found, please use a unique email address or contact the REMS Coordinating Center at 1-888-572-2934') {
                    component.set("v.errorMessage", result.status);
                    component.set("v.warningTheme", 'slds-box slds-theme_error slds-m-top_medium');
                    component.set("v.displayError",true);
                } else if (result.status == 'Account email address already exists for another account, please use a unique email address or contact the REMS Coordinating Center at 1-888-572-2934') {
                    component.set("v.errorMessage", result.status);
                    component.set("v.warningTheme", 'slds-box slds-theme_error slds-m-top_medium');
                    component.set("v.displayError",true);
                } else if (result.status == "Success") {
                    component.set("v.errorMessage", 'Result found please select an office contact to affiliate'); 
                    component.set("v.warningTheme", 'slds-box slds-theme_success slds-m-top_medium');
                    component.set("v.displayExistingContact",true);
                    component.set("v.isSubmitDisabled",false);
                    component.set("v.displaySuccess",true);
                    component.set("v.acctRec",result.account);
                    
                    
                }
                
            } else if (state === "ERROR") {
                component.set("v.isAccount", false);
                var errors = response.getError();
                
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        if(errors[0].message == 'No results match your search criteria. Add new Office Contact information in blank fields below') {
                            component.set("v.displayContactCreation",true);
                            component.set("v.isSearchDisabled", true);
                            component.set("v.isSubmitDisabled", false);
                            component.set("v.isFieldDisabled", true);  
                        }
                          component.set("v.errorMessage", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.displaySpinner", false);
        });

        $A.enqueueAction(action);
    },
    
    handleAffiliationSubmitHelper : function(component) {
          component.set("v.displaySpinner", true);
        
        if(!component.find("create-affiliation").get("v.checked")) {
            var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Missing record",
        "message": "Please choose a record to affiliate"
    });
    toastEvent.fire();
            return;
        }
        
        let accountRec = component.get('v.acctRec');
        
        accountRec.Two_Factor_Authentication_Selection__c = component.find("create-optin").get("v.checked") ? 'Opt-In' : '';
        
        
        
    
    let action = component.get("c.createAffiliation");
        action.setParams({
            oAccount : accountRec,
            isAccountUpdate : true
        });
        
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            } else {
                console.log('error',response.getError());
            }
            component.set("v.displaySpinner", false);
        });    
        $A.enqueueAction(action);
    
	}
})