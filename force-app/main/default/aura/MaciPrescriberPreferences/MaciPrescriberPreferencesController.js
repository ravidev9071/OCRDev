({
	doInit : function(component, event, helper) {
        component.set('v.ShowSpinner', true);
        helper.getProfessionalDesignationPicklist(component, event);
        helper.handleInit(component, event);
        helper.getstatePicklist(component, event);
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
        debugger;
         var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;
        
        if(component.get("v.pCase.US_WSREMS__First_Name__c") == undefined || component.get("v.pCase.US_WSREMS__Last_Name__c") == undefined 
           || component.get("v.pCase.Email_address__c") == undefined || component.get("v.pCase.US_WSREMS__Phone__c") == undefined  
           || component.get("v.pCase.US_WSREMS__First_Name__c") == '' || component.get("v.pCase.US_WSREMS__Last_Name__c") == ''
           || component.get("v.pCase.Email_address__c") == '' || component.get("v.pCase.US_WSREMS__Phone__c") == '' 
           || component.get("v.pCase.US_WSREMS__State__c") == undefined || component.get("v.pCase.US_WSREMS__State__c") == ''  
           || component.get("v.pCase.US_WSREMS__City__c") == undefined || component.get("v.pCase.US_WSREMS__City__c") == ''
           || component.get("v.pCase.US_WSREMS__Fax__c") == undefined || component.get("v.pCase.US_WSREMS__Fax__c") == ''
           || component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c") == undefined || component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c") == ''
           || component.get("v.pCase.US_WSREMS__Address_Line_1__c") == undefined || component.get("v.pCase.US_WSREMS__Address_Line_1__c") == '')
        {
            helper.showToast(component,event,'All fields are required.','Warning');
       
        }else if(component.get("v.pCase.US_WSREMS__Phone__c") != undefined && component.get("v.pCase.US_WSREMS__Phone__c") != '' && (!component.get("v.pCase.US_WSREMS__Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.pCase.US_WSREMS__Phone__c").match(alphaPattern))){
        	helper.showToast(component,event,'Please enter valid phone.','Warning');
        }else if(component.get("v.pCase.US_WSREMS__Fax__c") != undefined && component.get("v.pCase.US_WSREMS__Fax__c") != '' && (!component.get("v.pCase.US_WSREMS__Fax__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.pCase.US_WSREMS__Fax__c").match(alphaPattern) )){
                helper.showToast(component,event,'Please enter valid fax number.','Warning');
        }else if(component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c") != undefined && component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c") != '' && !component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c").match(zipcodepattern)){
                   helper.showToast(component,event,'Please enter valid Zip Code.','Warning'); 
        }else{
            component.set('v.ShowSpinner', true);
            helper.savePrescriberInfo(component, event);
        }
	},
    
    handleProfDesgOnChange : function(component, event, helper) {
        var profdesg =$("#pd").val();
        component.set("v.pCase.Professional_Designation__c",profdesg);
    },
    handleStateOnChange : function(component, event, helper) {
        
        var primaryState =$("#primaryState").val();
        component.set("v.pCase.US_WSREMS__State__c",primaryState);

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
    formatfaxNumber: function(component, helper, event) {
        var phoneNo = component.find("pfax");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.faxsize",phoneNumber.length);
        }else{
            component.set("v.faxsize",15);  
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