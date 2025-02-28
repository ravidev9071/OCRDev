({
    
    handleNext: function(component,event,helper){
        
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;
        var errorMsg='';
        
        if (component.get("v.oPharmyInfo.US_WSREMS__First_Name__c") == undefined || component.get("v.oPharmyInfo.US_WSREMS__First_Name__c") == ''){
            errorMsg += ' First Name,'
        }
        if (component.get("v.oPharmyInfo.US_WSREMS__Last_Name__c") == undefined || component.get("v.oPharmyInfo.US_WSREMS__Last_Name__c") == ''){
            errorMsg += ' Last Name,'
        }
        
        if (component.get("v.oPharmyInfo.Title__c") == undefined || component.get("v.oPharmyInfo.Title__c") == ''){
            errorMsg += ' Position/Title,'
        }
        
        if (component.get("v.oPharmyInfo.Credentials__c") == undefined || component.get("v.oPharmyInfo.Credentials__c") == ''){
            errorMsg += ' Credentials,'
        }
        
        if (component.get("v.oPharmyInfo.US_WSREMS__Email__c") == undefined || component.get("v.oPharmyInfo.US_WSREMS__Email__c") == ''){
            errorMsg += ' Email,'
        }
        
        if (component.get("v.confirmEmail") == undefined || component.get("v.confirmEmail") == ''){
            errorMsg += ' Confirm Email,'
        }
        
        if (component.get("v.oPharmyInfo.US_WSREMS__Phone__c") == undefined || component.get("v.oPharmyInfo.US_WSREMS__Phone__c") == ''){
            errorMsg += ' Phone,'
        }
        
        if (component.get("v.oPharmyInfo.US_WSREMS__Fax__c") == undefined || component.get("v.oPharmyInfo.US_WSREMS__Fax__c") == ''){
            errorMsg += ' Fax,'
        }
        
        if (errorMsg){
            errorMsg = errorMsg.replace(/,*$/, '.');
            errorMsg = 'Please enter '+errorMsg;
            helper.showToast(component,event,errorMsg,'Warning');
        }else if(!component.get("v.oPharmyInfo.US_WSREMS__Email__c").match(emailPattern)){
            helper.showToast(component,event,'Email format is incorrect, Please enter valid email address.','Warning');
        }else if(!component.get("v.confirmEmail").match(emailPattern)){
            helper.showToast(component,event,'Confirm Email format is incorrect, Please enter valid confirmEmail address.','Warning');
        }else if(component.get("v.oPharmyInfo.US_WSREMS__Email__c") != component.get("v.confirmEmail")){
            helper.showToast(component,event,'Email and Confirm emails are not matching. please enter valid email address.','Warning');
        }else if(component.get("v.oPharmyInfo.US_WSREMS__Phone__c") != '' && component.get("v.oPharmyInfo.US_WSREMS__Phone__c") != undefined && (!component.get("v.oPharmyInfo.US_WSREMS__Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.oPharmyInfo.US_WSREMS__Phone__c").match(alphaPattern))){
            helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(component.get("v.oPharmyInfo.US_WSREMS__Fax__c") != '' && component.get("v.oPharmyInfo.US_WSREMS__Fax__c") != undefined && (!component.get("v.oPharmyInfo.US_WSREMS__Fax__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.oPharmyInfo.US_WSREMS__Fax__c").match(alphaPattern))){
            helper.showToast(component,event,'Please enter valid Fax.','Warning'); 
        }else if(component.get("v.oPharmyInfo.Title__c") != '' && component.get("v.oPharmyInfo.Title__c") != undefined && component.get("v.oPharmyInfo.Title__c") == 'Other title' && (component.get("v.oPharmyInfo.Other_Title__c") == '' || component.get("v.oPharmyInfo.Other_Title__c") == undefined)){
            helper.showToast(component,event,'Please fill Other title.','Warning'); 
        }else if(component.get("v.oPharmyInfo.Credentials__c") != '' && component.get("v.oPharmyInfo.Credentials__c") != undefined && component.get("v.oPharmyInfo.Credentials__c") == 'Other' && (component.get("v.oPharmyInfo.Other_Credential__c") == '' || component.get("v.oPharmyInfo.Other_Credential__c") == undefined)){
            helper.showToast(component,event,'Please enter Other.','Warning'); 
        }
        else{
            component.set("v.ShowSpinner",true);
            helper.handleNextButton(component,event,helper);
        }
    },
    
    handleTitleOnChange : function(component, event, helper) {
        var title =$("#title").val();
        component.set("v.oPharmyInfo.Title__c",title);

    },
    
    handleCredentialsOnChange : function(component, event, helper) {
        var credential =$("#Credentials").val();
        component.set("v.oPharmyInfo.Credentials__c",credential);
    },
    
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'PharmacyEnrollment'); 
    },
    
    handleRefresh: function(component, event, helper) {
        component.set("v.oPharmyInfo.Other_Credential__c","");
        component.set("v.confirmEmail","");
        helper.handleRefresh(component,event);  
    },
    
    formatARPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("text-phone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
        component.set("v.arphonesize",phoneNumber.length);
        }else{
          component.set("v.arphonesize",15);  
        }
        
    },
    
    formatARFaxNumber: function(component, helper, event) {
        var phoneNo = component.find("text-fax");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
        component.set("v.arfaxsize",phoneNumber.length);
        }else{
          component.set("v.arfaxsize",15);  
        }
        
    }

    
})