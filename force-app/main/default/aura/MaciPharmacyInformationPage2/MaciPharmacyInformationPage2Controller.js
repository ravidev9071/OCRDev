({

    handleStateOnChange : function(component, event, helper) {
        
        var primaryState =$("#primaryState").val();
        component.set("v.newCase.US_WSREMS__State__c",primaryState);

    },
    
    handleShippingStateOnChange : function(component, event, helper) {
          
        var primaryState =$("#shippingState").val();
        component.set("v.newCase.State_Secondary_Office__c",primaryState);

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
        
        if (component.get("v.newCase.US_WSREMS__Address_Line_1__c") == undefined || component.get("v.newCase.US_WSREMS__City__c") == undefined 
           || component.get("v.newCase.US_WSREMS__REMS_Zip_Code__c") == undefined || component.get("v.newCase.US_WSREMS__State__c") == undefined 
           || component.get("v.newCase.US_WSREMS__Address_Line_1__c") == '' || component.get("v.newCase.US_WSREMS__City__c") == '' 
           || component.get("v.newCase.US_WSREMS__REMS_Zip_Code__c") == '' || component.get("v.newCase.US_WSREMS__State__c") == '' ){
            errorMsg += ' Mailing Address,'
        }
        
        if (component.get("v.newCase.US_WSREMS__Phone__c") == undefined || component.get("v.newCase.US_WSREMS__Phone__c") == ''){
            errorMsg += ' Mailing Phone,'
        }
        
        if (component.get("v.newCase.US_WSREMS__Fax__c") == undefined || component.get("v.newCase.US_WSREMS__Fax__c") == ''){
            errorMsg += ' Mailing Fax,'
        }
        
        if (component.get("v.newCase.Address_1_Secondary_Office__c") == undefined || component.get("v.newCase.City_Secondary_Office__c") == undefined 
           || component.get("v.newCase.SYN_Zip_Code__c") == undefined || component.get("v.newCase.State_Secondary_Office__c") == undefined 
           || component.get("v.newCase.Address_1_Secondary_Office__c") == '' || component.get("v.newCase.City_Secondary_Office__c") == '' 
           || component.get("v.newCase.SYN_Zip_Code__c") == '' || component.get("v.newCase.State_Secondary_Office__c") == ''){
            errorMsg += ' Shipping Address,'
        }
        
        if (component.get("v.newCase.Phone_Secondary_Office__c") == undefined || component.get("v.newCase.Phone_Secondary_Office__c") == ''){
            errorMsg += ' Shipping Phone,'
        }
        
        if (component.get("v.newCase.Fax_Secondary_Office__c") == undefined || component.get("v.newCase.Fax_Secondary_Office__c") == ''){
            errorMsg += ' Shipping Fax,'
        }
        
        
        if(errorMsg){
            errorMsg = errorMsg.replace(/,*$/, '.');
            errorMsg = 'Please enter '+errorMsg;
            helper.showToast(component,event,errorMsg,'Warning');
        }else if(!component.get("v.newCase.US_WSREMS__Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.US_WSREMS__Phone__c").match(alphaPattern)){
           helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(!component.get("v.newCase.US_WSREMS__Fax__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.US_WSREMS__Fax__c").match(alphaPattern)){
           helper.showToast(component,event,'Please enter valid Fax.','Warning'); 
        }else if(!component.get("v.newCase.US_WSREMS__REMS_Zip_Code__c").match(zipcodepattern)){
           helper.showToast(component,event,'Please enter valid Zip Code.','Warning'); 
        }else if(!component.get("v.newCase.Phone_Secondary_Office__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.Phone_Secondary_Office__c").match(alphaPattern)){
           helper.showToast(component,event,'Please enter valid phone (Shipping).','Warning'); 
        }else if(!component.get("v.newCase.Fax_Secondary_Office__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.Fax_Secondary_Office__c").match(alphaPattern)){
           helper.showToast(component,event,'Please enter valid Fax (Shipping).','Warning'); 
        }else if(!component.get("v.newCase.SYN_Zip_Code__c").match(zipcodepattern)){
           helper.showToast(component,event,'Please enter valid Zip Code (Shipping).','Warning'); 
        }else{
            helper.handleNextButton(component,event,helper);
        }
    },
    
    mailingAddressSelect : function(component, event, helper) {
        var userMailingAddress =$("#flexCheckDefault").is(':checked');
        if(userMailingAddress == true){
            component.set("v.newCase.Address_1_Secondary_Office__c",component.get("v.newCase.US_WSREMS__Address_Line_1__c"));
            component.set("v.newCase.City_Secondary_Office__c",component.get("v.newCase.US_WSREMS__City__c"));
            component.set("v.newCase.State_Secondary_Office__c",component.get("v.newCase.US_WSREMS__State__c"));
            component.set("v.newCase.SYN_Zip_Code__c",component.get("v.newCase.US_WSREMS__REMS_Zip_Code__c"));
            component.set("v.addressInfoObj.ShippingAddressLine2",component.get("v.addressInfoObj.MailingAddressLine2"));
            component.set("v.useMailingAddress","true");            
        }
        if(userMailingAddress == false){
            component.set("v.newCase.Address_1_Secondary_Office__c",'');
            component.set("v.newCase.City_Secondary_Office__c",'');
            component.set("v.newCase.State_Secondary_Office__c",'');
            component.set("v.newCase.SYN_Zip_Code__c",'');
            component.set("v.addressInfoObj.ShippingAddressLine2",'');
            component.set("v.useMailingAddress","false");            

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
    
    formatShipingPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("sprimaryContactPhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
       
        if(s.length >= 10){
            component.set("v.sphonesize",phoneNumber.length);
        }else{
            component.set("v.sphonesize",15);  
        }  
    },
    
    formatShippingFaxNumber: function(component, helper, event) {
        var phoneNo = component.find("sprimaryFax");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.sfaxsize",phoneNumber.length);
        }else{
            component.set("v.sfaxsize",15);  
        }  
    },
})