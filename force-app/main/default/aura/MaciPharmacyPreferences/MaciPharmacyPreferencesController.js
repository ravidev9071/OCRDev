({
    doInit : function(component, event, helper) {
        component.set('v.ShowSpinner', true);
        helper.getTitlePicklistValues(component, event); 
        helper.getCredentialsPicklistValues(component, event); 
        helper.handleInit(component, event);
    },
    
    handleEdit : function(component, event, helper) {
        component.set('v.isView', false);
	},
                      
    handleCancel : function(component, event, helper) {
        component.set('v.isView', true);
	},
    
    handleCredentialsOnChange : function(component, event, helper) {
        var credential =$("#Credentials").val();
        component.set("v.oPharmyInfo.Credentials__c",credential);
    },

    handleFAChange : function(component, event, helper) {
        if(component.get("v.value2FA") == 'Opt-Out'){
            component.set("v.show2FAOptOut",true);
        } else {
            component.set("v.show2FAOptOut",false);  
        }
        if(component.get("v.value2FA") != component.get("v.originalValue2FA")){
            component.set("v.show2FAOptionButton",true);
        }else{
            component.set("v.show2FAOptionButton",false);
        }
        
    },

    handle2FACancel : function(component, event, helper) {
        var originalValue2FA =  component.get("v.originalValue2FA");
        component.set("v.value2FA",originalValue2FA);
        component.set("v.show2FAOptionButton",false);
        
        
    },

    handle2FASave : function(component, event, helper) {
        var value2FA =  component.get("v.value2FA");
        component.set("v.originalValue2FA",value2FA);
        component.set("v.show2FAOptionButton",false);
        
        component.set('v.ShowSpinner', true);
        helper.savePharmacyTwoFA(component, event);
    },
})