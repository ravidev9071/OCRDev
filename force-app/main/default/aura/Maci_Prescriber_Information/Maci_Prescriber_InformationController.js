({
    doInit : function(component, event, helper) {
    },
    
    handleChange: function(component,event,helper){
        var cEmail = component.get("v.prescriberNPIObj.confirmEmail");
        component.set("v.prescriberNPIObj",{ 'firstName':'', 'middleName':'','lastName':'','addressLine1':'', 'city':'','state':'',
        'zipCode':'','confirmEmail':cEmail ,'Phone1':'','speciality':''});
       component.set('v.ShowNPIInfo',false);
    },

    findProviderInfo: function(component,event,helper){
        
        var npi = component.get("v.newCase.US_WSREMS__NPI__c");
        var numberpattern = /^(\s*\d\s*){10}$/;
        if(npi == '' || npi == undefined){
            helper.showToast(component,event,'Please fill valid NPI.','Warning');
        }else if(npi.length <10){
            helper.showToast(component,event,'Prescriber NPI should be 10 digits.','Warning');
        }else if(!npi.match(numberpattern)){
             helper.showToast(component,event,'Prescriber NPI should contain 10 digits.','Warning');
        }else{
             component.set("v.ShowSpinner",true);
             helper.getProviderDetails(component,event,helper);
        }
    },
    
    handleNext: function(component,event,helper){
        
		var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;
        var npi = component.get("v.newCase.US_WSREMS__NPI__c");
        var confirmEmail = component.get("v.prescriberNPIObj.confirmEmail");
        if(npi == '' || npi == undefined){
           helper.showToast(component,event,'Please fill valid NPI.','Warning');
        }else if(npi.length <10){
            helper.showToast(component,event,'Prescriber NPI should be 10 digits.','Warning');
        }else if(!npi.match(numberpattern)){
             helper.showToast(component,event,'Prescriber NPI should contain 10 digits.','Warning');
        }else if(component.get("v.prescriberNPIObj.lastName") == '' || component.get("v.prescriberNPIObj.lastName") == undefined){
             helper.showToast(component,event,'Prescriber Name is required.','Warning');
        }else if(component.get("v.newCase.Email_address__c") == '' || component.get("v.newCase.Email_address__c") == undefined){
           helper.showToast(component,event,'Please fill valid email.','Warning');
        }else if(!component.get("v.newCase.Email_address__c").match(emailPattern)){
            helper.showToast(component,event,'Please fill valid email address.','Warning');
        }else if(confirmEmail == '' || confirmEmail == undefined){
           helper.showToast(component,event,'Please fill confirm email.','Warning');
        }else if(!confirmEmail.match(emailPattern)){
            helper.showToast(component,event,'Please fill valid confirm email address.','Warning');
        }else if(component.get("v.newCase.Email_address__c") != confirmEmail){
           helper.showToast(component,event,'Email and Confirm Email are not matching, Please enter valid confirm email address.','Warning');
        }else if(component.get("v.newCase.Professional_Designation__c") == '' || component.get("v.newCase.Professional_Designation__c") == undefined){
            helper.showToast(component,event,'Please fill Professional Designation.','Warning');
        }else if(component.get("v.newCase.US_WSREMS__REMS_Alternate_Phone__c") != '' 
                 && component.get("v.newCase.US_WSREMS__REMS_Alternate_Phone__c") != undefined
                 && (!component.get("v.newCase.US_WSREMS__REMS_Alternate_Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.US_WSREMS__REMS_Alternate_Phone__c").match(alphaPattern))){
           		helper.showToast(component,event,'Please enter valid phone number.','Warning');
        }else{
            helper.handleNextButton(component,event); 
            component.set("v.ShowSpinner",true);
        }
 
    },
    
    handleRefresh: function(component, event, helper) {
       helper.handleRefresh(component,event);  
    },
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'certficationScreen');
    },

    handleProfDesgOnChange : function(component, event, helper) {
        var profdesg =$("#pd").val();
        component.set("v.newCase.Professional_Designation__c",profdesg);

    },
    formatPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("staffphone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
        	component.set("v.defaultSize",phoneNumber.length);
        }else{
          	component.set("v.defaultSize",15);  
        }
        
    }
    
})