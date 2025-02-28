({
	doInit: function(component, event, helper) {  
        helper.getCurrentPharmacistInfo(component,event);
        helper.getTitlePicklistValues(component, event); 
        helper.getCredentialsPicklistValues(component, event); 
    },
    
    handleTitleOnChange : function(component, event, helper) {
        var title =$("#title").val();
        component.set("v.oPharmyInfo.Title__c",title);

    },
    
    handleCredentialsOnChange : function(component, event, helper) {
        var credential =$("#Credentials").val();
        component.set("v.oPharmyInfo.Credentials__c",credential);
    },
    
    handleNext: function(component,event,helper){
        
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var termsCondition  = component.get("v.termsFlag");
        if(   component.get("v.oPharmyInfo.US_WSREMS__First_Name__c") == undefined || component.get("v.oPharmyInfo.US_WSREMS__Last_Name__c") == undefined 
           || component.get("v.oPharmyInfo.Title__c")== undefined ||component.get("v.oPharmyInfo.Credentials__c") == undefined 
           || component.get("v.oPharmyInfo.US_WSREMS__Email__c") == undefined  
           || component.get("v.oPharmyInfo.US_WSREMS__First_Name__c") == '' || component.get("v.oPharmyInfo.US_WSREMS__Last_Name__c") == ''
           || component.get("v.oPharmyInfo.Title__c")== '' || component.get("v.oPharmyInfo.Credentials__c") == ''
           || component.get("v.oPharmyInfo.US_WSREMS__Email__c") == ''
          )
        {
            helper.showToast(component,event,'All fields are required.','Warning');
        }else if(!component.get("v.oPharmyInfo.US_WSREMS__Email__c").match(emailPattern)){
            helper.showToast(component,event,'Email format is incorrect, Please enter valid email address.','Warning');
        }else if(!component.get("v.confirmEmail").match(emailPattern)){
            helper.showToast(component,event,'confirmEmail format is incorrect, Please enter valid confirmEmail address.','Warning');
        }else if(component.get("v.oPharmyInfo.US_WSREMS__Email__c") != component.get("v.confirmEmail")){
            helper.showToast(component,event,'Email and Confirm emails are not matching. please enter valid email address.','Warning');
        }else if(component.get("v.oPharmyInfo.Title__c") != '' && component.get("v.oPharmyInfo.Title__c") != undefined && component.get("v.oPharmyInfo.Title__c") == 'Other title' && (component.get("v.oPharmyInfo.Other_Title__c") == '' || component.get("v.oPharmyInfo.Other_Title__c") == undefined)){
            helper.showToast(component,event,'Please fill Other title.','Warning'); 
        }else if(component.get("v.oPharmyInfo.Credentials__c") != '' && component.get("v.oPharmyInfo.Credentials__c") != undefined && component.get("v.oPharmyInfo.Credentials__c") == 'Other' && (component.get("v.oPharmyInfo.Other_Credential__c") == '' || component.get("v.oPharmyInfo.Other_Credential__c") == undefined)){
            helper.showToast(component,event,'Please fill Other.','Warning'); 
        }else if(termsCondition == false){
            helper.showToast(component,event,'Please agree the terms & conditions','Warning'); 
        }
        else{
            component.set("v.ShowSpinner",true);
            helper.handleNextButton(component,event,helper);
        }
    },
    
     termsConidtionSelect : function(component, event, helper) {
        var tflag = $("#flexCheckDefault").is(':checked');
        component.set("v.termsFlag",tflag);
    }
    
})