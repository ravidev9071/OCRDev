({
    doInit: function(component, event, helper) {     
        component.set("v.mailingAddressInfoObj.Address1",component.get("v.newCase.US_WSREMS__Address_Line_1__c")); 
        component.set("v.mailingAddressInfoObj.AddressLine2",component.get("v.newCase.US_WSREMS__Address_Line_2__c"));
        component.set("v.mailingAddressInfoObj.city",component.get("v.newCase.US_WSREMS__City__c"));
        component.set("v.mailingAddressInfoObj.state",component.get("v.newCase.US_WSREMS__State__c"));
        component.set("v.mailingAddressInfoObj.zipcode",component.get("v.newCase.US_WSREMS__REMS_Zip_Code__c"));   
    },
    handleStateOnChange : function(component, event, helper) {
         
        var primaryState =$("#primaryState").val();
        component.set("v.mailingAddressInfoObj.state",primaryState);

    },
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'PharmCNPIScreen'); 
    },
    handleNext: function(component,event,helper){
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;
        var errorMsg='';
        
        if (component.get("v.mailingAddressInfoObj.Address1") == undefined || component.get("v.mailingAddressInfoObj.Address1") == ''){
            errorMsg += ' Address Line 1,'
        }
        
        if (component.get("v.mailingAddressInfoObj.city") == undefined || component.get("v.mailingAddressInfoObj.city") == ''){
            errorMsg += ' City,'
        }
        
        if (component.get("v.mailingAddressInfoObj.state") == undefined || component.get("v.mailingAddressInfoObj.state") == ''){
            errorMsg += ' State,'
        }
        
        if (component.get("v.mailingAddressInfoObj.zipcode") == undefined || component.get("v.mailingAddressInfoObj.zipcode") == ''){
            errorMsg += ' Zip Code,'
        }
        
        if (component.get("v.newCase.US_WSREMS__Phone__c") == undefined || component.get("v.newCase.US_WSREMS__Phone__c") == ''){
            errorMsg += ' Phone,'
        }
        
        if (component.get("v.newCase.US_WSREMS__Fax__c") == undefined || component.get("v.newCase.US_WSREMS__Fax__c") == ''){
            errorMsg += ' Fax,'
        }
        
        if (errorMsg){
            errorMsg = errorMsg.replace(/,*$/, '.');
            errorMsg = 'Please enter '+errorMsg;
            helper.showToast(component,event,errorMsg,'Warning');
        }else if(!component.get("v.newCase.US_WSREMS__Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.US_WSREMS__Phone__c").match(alphaPattern)){
           helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(!component.get("v.newCase.US_WSREMS__Fax__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.US_WSREMS__Fax__c").match(alphaPattern)){
           helper.showToast(component,event,'Please enter valid Fax.','Warning'); 
        }else if(!component.get("v.mailingAddressInfoObj.zipcode").match(zipcodepattern)){
           helper.showToast(component,event,'Please enter valid Zip Code.','Warning'); 
        }else{
            helper.handleNextButton(component,event,helper);
        }
    },
    formatMailingPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("primaryContactPhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
       
        if(s.length >= 10){
            component.set("v.mphonesize",phoneNumber.length);
        }else{
            component.set("v.mphonesize",15);  
        }  
    },
    
    formatMailingFaxNumber: function(component, helper, event) {
        var phoneNo = component.find("primaryFax");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.mfaxsize",phoneNumber.length);
        }else{
            component.set("v.mfaxsize",15);  
        }  
    },
})