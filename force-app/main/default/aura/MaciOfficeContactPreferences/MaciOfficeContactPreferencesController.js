({
	doInit : function(component, event, helper) {
        component.set('v.ShowSpinner', true);
        helper.handleInit(component, event);
	},
    
    handleEdit : function(component, event, helper) {
        component.set('v.isView', false);
	},
                      
    handleCancel : function(component, event, helper) {
        var originalValue2FA =  component.get("v.originalValue2FA");
        component.set("v.value2FA",originalValue2FA);
        component.set('v.isView', true);
	},
                      
    handleSave : function(component, event, helper) {
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;
        
        if(component.get("v.pCase.US_WSREMS__First_Name__c") == undefined || component.get("v.pCase.US_WSREMS__Last_Name__c") == undefined 
           || component.get("v.pCase.US_WSREMS__Email_ar__c") == undefined || component.get("v.pCase.Phone_Secondary_Office__c") == undefined  
           || component.get("v.pCase.US_WSREMS__First_Name__c") == '' || component.get("v.pCase.US_WSREMS__Last_Name__c") == ''
           || component.get("v.pCase.US_WSREMS__Email_ar__c") == '' || component.get("v.pCase.Phone_Secondary_Office__c") == '' )
        {
            helper.showToast(component,event,'All fields are required.','Warning');
       
        }else if(component.get("v.pCase.Phone_Secondary_Office__c") != undefined && component.get("v.pCase.Phone_Secondary_Office__c") != '' && (!component.get("v.pCase.Phone_Secondary_Office__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.pCase.Phone_Secondary_Office__c").match(alphaPattern))){
        	helper.showToast(component,event,'Please enter valid phone.','Warning');
        }else{ 
            component.set('v.ShowSpinner', true);
            helper.saveOfficeContactInfo(component, event);
        }
	},
    
    formatPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("pPhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.phonesize",phoneNumber.length);
        }else{
            component.set("v.phonesize",15);  
        }
        
    },
    handleFAChange : function(component, event, helper) {
        if(component.get("v.value2FA") == 'Opt-Out'){
            component.set("v.show2FAOptOut",true);
        } else {
            component.set("v.show2FAOptOut",false);  
        }

    },          
})