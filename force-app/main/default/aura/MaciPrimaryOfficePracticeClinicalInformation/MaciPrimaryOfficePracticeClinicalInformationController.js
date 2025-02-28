({  
    doInit: function(component, event, helper) {     
       var preferMethod = component.get("v.pCase.US_WSREMS__Preferred_Contact_Method__c");
       if(preferMethod == 'Email'){
           component.set("v.ppmEmail",true);  
       }else if(preferMethod == 'Phone'){
           component.set("v.ppmPhone",true);  
       }else if(preferMethod == 'Fax'){
           component.set("v.ppmFax",true);
       }
       var isNPILocationSelected = component.get("v.primaryOtherInfoObj.isNPILocationSelected");
               

        if(isNPILocationSelected == "true"){
            component.set("v.npiLocation",true);
        }else{
			component.set("v.npiLocation",false);      
    	}
        
        // Initialize current screen name
        component.set("v.currentScreenName", "PrimaryOffice"); // Set the initial screen name
        
    },
    
    showOfficeAddress: function(component, event, helper) {
        var userNpiLocation = $("#flexCheckDefault").is(":checked"); //$("#flexCheckDefault").val();
        
        if(userNpiLocation == true){
            component.set("v.pCase.US_WSREMS__Address_Line_1__c",component.get("v.prescriberNPIObj.addressLine1")); 
            component.set("v.pCase.US_WSREMS__City__c",component.get("v.prescriberNPIObj.city"));
            component.set("v.pCase.US_WSREMS__State__c",component.get("v.prescriberNPIObj.state"));
            component.set("v.pCase.US_WSREMS__REMS_Zip_Code__c",component.get("v.prescriberNPIObj.zipCode"));
            component.set("v.primaryOtherInfoObj.isNPILocationSelected","true");
        } else{
            component.set("v.pCase.US_WSREMS__Address_Line_1__c",""); 
            component.set("v.pCase.US_WSREMS__City__c","");
            component.set("v.pCase.US_WSREMS__State__c","");
            component.set("v.pCase.US_WSREMS__REMS_Zip_Code__c","");
            component.set("v.primaryOtherInfoObj.isNPILocationSelected","false");
        }
         
    },
    
	handleNext: function(component,event,helper){
       
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
		var extpattern = /^\d{1,5}$/;
        var alphaPattern = /[a-zA-Z]/g;
        var headerMessage = 'Please complete all the required fields: ';
         var errorMsg='';
        
        if(component.get("v.pCase.Office_Practice_Clinic_Name__c") == undefined || component.get("v.pCase.Office_Practice_Clinic_Name__c") == ''){
            errorMsg += ' Office practice/clinic name,'
        }
        
        if(component.get("v.pCase.Specialty__c") == undefined || component.get("v.pCase.Specialty__c") == ''){
            errorMsg += ' Specialty,'
        }
        
        if(component.get("v.pCase.US_WSREMS__Address_Line_1__c") == undefined || component.get("v.pCase.US_WSREMS__Address_Line_1__c") == ''){
            errorMsg += ' Address Line1,'
        }
        
        if(component.get("v.pCase.US_WSREMS__City__c") == undefined || component.get("v.pCase.US_WSREMS__City__c") == ''){
            errorMsg += ' City,'
        }
        
        if(component.get("v.pCase.US_WSREMS__State__c") == undefined || component.get("v.pCase.US_WSREMS__State__c") == ''){
            errorMsg += ' State,'
        }
        
        if(component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c") == undefined || component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c") == ''){
            errorMsg += ' Zip Code,'
        }
        
        if(component.get("v.pCase.US_WSREMS__Phone__c") == undefined || component.get("v.pCase.US_WSREMS__Phone__c") == ''){
            errorMsg += ' Phone,'
        }
        
        if(component.get("v.pCase.US_WSREMS__Fax__c") == undefined || component.get("v.pCase.US_WSREMS__Fax__c") == ''){
            errorMsg += ' Fax,'
        }
        //First Name Validation
        if(component.get("v.primaryOtherInfoObj.firstName") != undefined && component.get("v.primaryOtherInfoObj.firstName") != '' ) {
            if(component.get("v.primaryOtherInfoObj.lastName") == undefined || component.get("v.primaryOtherInfoObj.lastName") == ''){
                errorMsg += ' Last Name,'
            }
            // if(component.get("v.pCase.Email_address__c") == undefined || component.get("v.pCase.Email_address__c") == ''){
            //     errorMsg += ' Email '
            // }
        } 
        //Last Name Validation
        if(component.get("v.primaryOtherInfoObj.lastName") != undefined && component.get("v.primaryOtherInfoObj.lastName") != '') {
            if(component.get("v.primaryOtherInfoObj.firstName") == undefined || component.get("v.primaryOtherInfoObj.firstName") == ''){
                errorMsg += ' First Name,'
            }
            // if(component.get("v.pCase.Email_address__c") == undefined || component.get("v.pCase.Email_address__c") == ''){
            //     errorMsg += ' Email '
            // }
        } 
        //Email Validation
        if(component.get("v.primaryOtherInfoObj.confirmEmail") != undefined && component.get("v.primaryOtherInfoObj.confirmEmail") != '' ){
            if(component.get("v.pCase.Email_address__c") == undefined || component.get("v.pCase.Email_address__c") == ''){
                errorMsg += ' Email,'
            }
        } 
        if(component.get("v.pCase.Email_address__c") != undefined && component.get("v.pCase.Email_address__c") != '' ){
            if(component.get("v.primaryOtherInfoObj.confirmEmail") == undefined || component.get("v.primaryOtherInfoObj.confirmEmail") == ''){
                errorMsg += ' Confirm Email,'
            }
        } 
        if(errorMsg){
            errorMsg = errorMsg.replace(/,*$/, '.');
            errorMsg = 'Please enter '+errorMsg;
            helper.showToast(component,event,errorMsg,'Warning');
        }else if(component.get("v.pCase.US_WSREMS__Email__c") != '' && component.get("v.pCase.US_WSREMS__Email__c") != undefined && !component.get("v.pCase.US_WSREMS__Email__c").match(emailPattern)){
           helper.showToast(component,event,'Email format is incorrect, Please enter valid email address.','Warning');
        }else if(component.get("v.primaryOtherInfoObj.confirmEmail") != '' && component.get("v.primaryOtherInfoObj.confirmEmail") !=  undefined && !component.get("v.primaryOtherInfoObj.confirmEmail").match(emailPattern)){
           helper.showToast(component,event,'Confirm Email format is incorrect, Please enter valid confirm email address.','Warning');
        }else if(component.get("v.pCase.US_WSREMS__Email__c") != '' && component.get("v.pCase.US_WSREMS__Email__c") != undefined && component.get("v.primaryOtherInfoObj.confirmEmail") != '' && component.get("v.primaryOtherInfoObj.confirmEmail") !=  undefined && component.get("v.pCase.US_WSREMS__Email__c") != component.get("v.primaryOtherInfoObj.confirmEmail")){
           helper.showToast(component,event,'Email and Confirm Email are not matching, Please enter valid confirm email address.','Warning');
        }else if(component.get("v.pCase.US_WSREMS__Phone__c") != undefined && component.get("v.pCase.US_WSREMS__Phone__c") != '' && (!component.get("v.pCase.US_WSREMS__Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.pCase.US_WSREMS__Phone__c").match(alphaPattern) )){
           helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(component.get("v.pCase.US_WSREMS__REMS_Office_Contact_Phone__c") != undefined && component.get("v.pCase.US_WSREMS__REMS_Office_Contact_Phone__c") != '' && (!component.get("v.pCase.US_WSREMS__REMS_Office_Contact_Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.pCase.US_WSREMS__REMS_Office_Contact_Phone__c").match(alphaPattern))){
           helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(component.get("v.pCase.US_WSREMS__REMS_Ext__c") != null && component.get("v.pCase.US_WSREMS__REMS_Ext__c") != '' && !component.get("v.pCase.US_WSREMS__REMS_Ext__c").match(extpattern)){
            helper.showToast(component,event,'Please enter valid Ext.','Warning');
        }else if(component.get("v.pCase.US_WSREMS__Fax__c") != undefined && component.get("v.pCase.US_WSREMS__Fax__c") != '' && (!component.get("v.pCase.US_WSREMS__Fax__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.pCase.US_WSREMS__Fax__c").match(alphaPattern))){
           helper.showToast(component,event,'Please enter valid Fax.','Warning'); 
        }else if(!component.get("v.pCase.US_WSREMS__REMS_Zip_Code__c").match(zipcodepattern)){
           helper.showToast(component,event,'Please enter valid Zip Code.','Warning'); 
        }else {
            helper.handleNextButton(component, event, helper);
            component.set("v.ShowSpinner",true);
        }
        
    },
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'PrescriberInformation'); 
    },
    
    handleRefresh: function(component, event, helper) {
        component.set("v.primaryOtherInfoObj.isNPILocationSelected","false");
        component.set("v.npiLocation",false);
        component.set("v.ppmFax",false);
        component.set("v.ppmPhone",false);
        component.set("v.ppmEmail",false);
        component.set("v.pCase.US_WSREMS__Preferred_Contact_Method__c","");
        helper.handleRefresh(component,event);  
    },
    
    handleStateOnChange : function(component, event, helper) {
         var primaryState =$("#primaryState").val();
        component.set("v.pCase.US_WSREMS__State__c",primaryState);

    },
    emailSelect : function(component, event, helper) {
        component.set("v.ppmFax",false);
        component.set("v.ppmPhone",false);
        component.set("v.ppmEmail",true);
        component.set("v.pCase.US_WSREMS__Preferred_Contact_Method__c",'Email');
    },
    phoneSelect : function(component, event, helper) {
        component.set("v.ppmFax",false);
        component.set("v.ppmPhone",true);
        component.set("v.ppmEmail",false);
        component.set("v.pCase.US_WSREMS__Preferred_Contact_Method__c",'Phone');
    },
    faxSelect : function(component, event, helper) {
        component.set("v.ppmFax",true);
        component.set("v.ppmPhone",false);
        component.set("v.ppmEmail",false);
        component.set("v.pCase.US_WSREMS__Preferred_Contact_Method__c",'Fax');
    },
    
    formatPrimaryNumber: function(component, helper, event) {
        var phoneNo = component.find("primaryContactPhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.phonesize",phoneNumber.length);
        }else{
            component.set("v.phonesize",15);  
        }
        
    },
    
    formatOfficePhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("primaryContactOfficePhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.officephonesize",phoneNumber.length);
        }else{
            component.set("v.officephonesize",15);  
        }
        
    },
    
    formatOfficeFaxNumber: function(component, helper, event) {
        var phoneNo = component.find("primaryFax");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.officefax",phoneNumber.length);
        }else{
            component.set("v.officefax",15);  
        }
        
    },
    handleYes: function(component, event, helper) {
        
        var evt = component.getEvent("ShowPrescriberScreens");
        evt.setParams({
            "showScreen": true,
            "screenName": "SecondaryOffice",
            "pCase": component.get("v.pCase"),
            "primaryOtherInfoObj": component.get("v.primaryOtherInfoObj")
        });
        evt.fire();
        component.set("v.currentScreenName", "SecondaryOffice"); // Track current screen
        component.set("v.isModalOpen",false);
    },

    
    handleNo: function(component, event, helper) {
        var currentScreenName = component.get("v.currentScreenName");
        
        if (currentScreenName === "SecondaryOffice") {
            var evt = component.getEvent("ShowPrescriberScreens");
            evt.setParams({
                "showScreen": true,
                "screenName": "PrimaryOffice",
                "pCase": component.get("v.pCase"),
                "primaryOtherInfoObj": component.get("v.primaryOtherInfoObj")
            });
            evt.fire();
            component.set("v.currentScreenName", "PrimaryOffice"); // Track current screen

            helper.showToast(component, event, 'Office Contact exists, please re-enter', 'Warning');
        } else {
            var evt = component.getEvent("ShowPrescriberScreens");
            evt.setParams({
                "showScreen": true,
                "screenName": "PrimaryOffice",
                "pCase": component.get("v.pCase"),
                "primaryOtherInfoObj": component.get("v.primaryOtherInfoObj")
            });
            evt.fire();
            helper.showToast(component, event, 'Office Contact exists, please re-enter', 'Warning');
         }
         component.set("v.isModalOpen",false);
    },    
    

})