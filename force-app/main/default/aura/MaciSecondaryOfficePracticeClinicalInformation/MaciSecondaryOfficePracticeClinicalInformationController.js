({  
    doInit: function(component, event, helper) {     
        var preferMethod = component.get("v.sCase.Preferred_Contact_Method_Secondary_Offic__c");
        if(preferMethod == 'Email'){
            component.set("v.ppmEmail",true);  
        }else if(preferMethod == 'Phone'){
            component.set("v.ppmPhone",true);  
        }else if(preferMethod == 'Fax'){
            component.set("v.ppmFax",true);
        }
        var isNPILocationSelected = component.get("v.secondaryOtherInfoObj.isNPILocationSelected");
         if(isNPILocationSelected == "true"){
             component.set("v.npiLocation",true);
         }else{
             component.set("v.npiLocation",false);      
         }
         component.set("v.currentScreenName", "SecondaryOffice");
         
    },

    showOfficeAddress: function(component, event, helper) {
        var userNpiLocation = $("#flexCheckDefault").is(":checked"); 
       
     
        if(userNpiLocation == true){
            component.set("v.sCase.Address_1_Secondary_Office__c",component.get("v.prescriberNPIObj.addressLine1")); 
            component.set("v.sCase.City_Secondary_Office__c",component.get("v.prescriberNPIObj.city"));
            component.set("v.sCase.State_Secondary_Office__c",component.get("v.prescriberNPIObj.state"));
            component.set("v.sCase.SYN_Zip_Code__c",component.get("v.prescriberNPIObj.zipCode"));
            component.set("v.secondaryOtherInfoObj.isNPILocationSelected","true");
        }else{
            component.set("v.sCase.Address_1_Secondary_Office__c",""); 
            component.set("v.sCase.City_Secondary_Office__c","");
            component.set("v.sCase.State_Secondary_Office__c","");
            component.set("v.sCase.SYN_Zip_Code__c","");
            component.set("v.secondaryOtherInfoObj.isNPILocationSelected","false");
        }
    },
    handleNext: function(component,event,helper){
       	var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
		var extpattern = /^\d{1,5}$/;
        var alphaPattern = /[a-zA-Z]/g;
        var errorMsg='';
        //First Name Validation
        if(component.get("v.secondaryOtherInfoObj.firstName") != undefined && component.get("v.secondaryOtherInfoObj.firstName") != '' ) {
            if(component.get("v.secondaryOtherInfoObj.lastName") == undefined || component.get("v.secondaryOtherInfoObj.lastName") == ''){
                errorMsg += ' Last Name,'
            }
           
        } 
        //Last Name Validation
        if(component.get("v.secondaryOtherInfoObj.lastName") != undefined && component.get("v.secondaryOtherInfoObj.lastName") != '') {
            if(component.get("v.secondaryOtherInfoObj.firstName") == undefined || component.get("v.secondaryOtherInfoObj.firstName") == ''){
                errorMsg += ' First Name,'
            }
           
        } 
        
        //Email Validation
         if(component.get("v.secondaryOtherInfoObj.confirmEmail") != undefined && component.get("v.secondaryOtherInfoObj.confirmEmail") != '' ){
            if(component.get("v.sCase.Email_Secondary_Office__c") == undefined || component.get("v.sCase.Email_Secondary_Office__c") == ''){
                errorMsg += ' Email,'
            }
        } 
        if(component.get("v.sCase.Email_Secondary_Office__c") != undefined && component.get("v.sCase.Email_Secondary_Office__c") != '' ){
            if(component.get("v.secondaryOtherInfoObj.confirmEmail") == undefined || component.get("v.secondaryOtherInfoObj.confirmEmail") == ''){
                errorMsg += ' Confirm Email,'
            }
        } 

        if(errorMsg){
            errorMsg = errorMsg.replace(/,*$/, '.');
            errorMsg = 'Please enter '+errorMsg;
            helper.showToast(component,event,errorMsg,'Warning');
        }else if(component.get("v.pCase.US_WSREMS__Email__c") != '' && component.get("v.pCase.US_WSREMS__Email__c") != undefined && !component.get("v.pCase.US_WSREMS__Email__c").match(emailPattern)){
           helper.showToast(component,event,'Email format is incorrect, Please enter valid email address.','Warning');
        }else if(component.get("v.secondaryOtherInfoObj.confirmEmail") != undefined && component.get("v.secondaryOtherInfoObj.confirmEmail") != '' && !component.get("v.secondaryOtherInfoObj.confirmEmail").match(emailPattern)){
           helper.showToast(component,event,'Confirm Email format is incorrect, Please enter valid confirm email address.','Warning');
        }else if(component.get("v.sCase.Email_Secondary_Office__c") != undefined && component.get("v.sCase.Email_Secondary_Office__c") != '' &&
                 component.get("v.secondaryOtherInfoObj.confirmEmail") != undefined && component.get("v.secondaryOtherInfoObj.confirmEmail") != '' &&  
                 component.get("v.sCase.Email_Secondary_Office__c") != component.get("v.secondaryOtherInfoObj.confirmEmail")){
           			helper.showToast(component,event,'Email and Confirm Email are not matching, Please enter valid confirm email address.','Warning');
        }else if(component.get("v.sCase.Phone_Secondary_Office__c") != undefined && component.get("v.sCase.Phone_Secondary_Office__c") != '' && (!component.get("v.sCase.Phone_Secondary_Office__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.sCase.Phone_Secondary_Office__c").match(alphaPattern))){
           helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(component.get("v.sCase.office_contact_phone_Secondary_Office__c") != undefined && component.get("v.sCase.office_contact_phone_Secondary_Office__c") != '' && (!component.get("v.sCase.office_contact_phone_Secondary_Office__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.sCase.office_contact_phone_Secondary_Office__c").match(alphaPattern))){
           helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(component.get("v.sCase.Ext_Secondary_Office__c") != undefined && component.get("v.sCase.Ext_Secondary_Office__c") != '' && !component.get("v.sCase.Ext_Secondary_Office__c").match(extpattern)){
           helper.showToast(component,event,'Please enter valid Ext.','Warning'); 
        }else if(component.get("v.sCase.Fax_Secondary_Office__c") != undefined && component.get("v.sCase.Fax_Secondary_Office__c") != '' && (!component.get("v.sCase.Fax_Secondary_Office__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.sCase.Fax_Secondary_Office__c").match(alphaPattern))){
           helper.showToast(component,event,'Please enter valid Fax.','Warning'); 
        }else if(component.get("v.sCase.SYN_Zip_Code__c") != undefined && component.get("v.sCase.SYN_Zip_Code__c") != '' && !component.get("v.sCase.SYN_Zip_Code__c").match(zipcodepattern)){
           helper.showToast(component,event,'Please enter valid Zip Code.','Warning'); 
        }else{
            helper.handleNextButton(component,event,helper);
            component.set("v.ShowSpinner",true);
        }
    },
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'PrimaryOffice');
    },
    handleRefresh: function(component, event, helper) {
         component.set("v.secondaryOtherInfoObj.isNPILocationSelected","false");
        component.set("v.npiLocation",false);
        component.set("v.ppmFax",false);
        component.set("v.ppmPhone",false);
        component.set("v.ppmEmail",false);
        component.set("v.sCase.Preferred_Contact_Method_Secondary_Offic__c","");
        helper.handleRefresh(component,event);
    },
    handleStateOnChange : function(component, event, helper) {
        
        var primaryState =$("#secondaryState").val();
        component.set("v.sCase.State_Secondary_Office__c",primaryState);

    },
    emailSelect : function(component, event, helper) {
        component.set("v.ppmFax",false);
        component.set("v.ppmPhone",false);
        component.set("v.ppmEmail",true);
        component.set("v.sCase.Preferred_Contact_Method_Secondary_Offic__c",'Email');
    },
    phoneSelect : function(component, event, helper) {
        component.set("v.ppmFax",false);
        component.set("v.ppmPhone",true);
        component.set("v.ppmEmail",false);
        component.set("v.sCase.Preferred_Contact_Method_Secondary_Offic__c",'Phone');
    },
    faxSelect : function(component, event, helper) {
        component.set("v.ppmFax",true);
        component.set("v.ppmPhone",false);
        component.set("v.ppmEmail",false);
        component.set("v.sCase.Preferred_Contact_Method_Secondary_Offic__c",'Fax');
    },
    formatPrimaryNumber: function(component, helper, event) {
        var phoneNo = component.find("secondaryContactPhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
      
        if(s.length >= 10){
            component.set("v.sphonesize",phoneNumber.length);
        }else{
            component.set("v.sphonesize",15);  
        }
        
    },
    
    formatOfficePhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("secondaryContactOfficePhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
       
        if(s.length >= 10){
            component.set("v.sofficephonesize",phoneNumber.length);
        }else{
            component.set("v.sofficephonesize",15);  
        }
        
    },
    
    formatOfficeFaxNumber: function(component, helper, event) {
        var phoneNo = component.find("secondaryFax");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
       
        if(s.length >= 10){
            component.set("v.sofficefax",phoneNumber.length);
        }else{
            component.set("v.sofficefax",15);  
        }
        
    },
    handleYes: function(component, event, helper) {
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
            "showScreen" : true,
            "screenName": "Password",
            "sCase" : component.get("v.sCase"),
            "secondaryOtherInfoObj" : component.get("v.secondaryOtherInfoObj")
        });
        evt.fire();
        component.set("v.currentScreenName", "Password"); // Track current screen
        component.set("v.isModalOpen",false);
    },

    
    handleNo: function(component, event, helper) {
        var currentScreenName = component.get("v.currentScreenName");
        if (currentScreenName === "Password") {
            var evt = component.getEvent("ShowPrescriberScreens");
            evt.setParams({
                "showScreen" : true,
                "screenName": "SecondaryOffice",
                "sCase" : component.get("v.sCase"),
                "secondaryOtherInfoObj" : component.get("v.secondaryOtherInfoObj")
            });
            evt.fire();
            component.set("v.currentScreenName", "SecondaryOffice"); // Track current screen
            helper.showToast(component, event, 'Office Contact exists, please re-enter', 'Warning');
        } else {
            var evt = component.getEvent("ShowPrescriberScreens");
            var evt = component.getEvent("ShowPrescriberScreens");
            evt.setParams({
                "showScreen" : true,
                "screenName": "SecondaryOffice",
                "sCase" : component.get("v.sCase"),
                "secondaryOtherInfoObj" : component.get("v.secondaryOtherInfoObj")
            });
            evt.fire();
            helper.showToast(component, event, 'Office Contact exists, please re-enter', 'Warning');
         }
         component.set("v.isModalOpen",false);
    },    
   
    
})