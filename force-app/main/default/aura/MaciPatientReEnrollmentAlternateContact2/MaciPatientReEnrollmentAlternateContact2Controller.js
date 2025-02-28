({  
 
	handleNext: function(component,event,helper){
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;
		
		if(component.get("v.alternateContactObj.emergencyContactPhoneNum") != undefined && component.get("v.alternateContactObj.emergencyContactPhoneNum") != '' ){
            component.set("v.lCase.Emergency_Contact_Phone__c",component.get("v.alternateContactObj.emergencyContactPhoneNum"));
        }
		
        if(component.get("v.isPatientMinor") == true && (component.get("v.alternateContactObj.lgfirstName") == undefined || component.get("v.alternateContactObj.lgfirstName") == '' ||
        component.get("v.alternateContactObj.lglastName") == undefined || component.get("v.alternateContactObj.lglastName") == '' ||
        component.get("v.lCase.Legal_Guardian_Relationship__c") == undefined || component.get("v.lCase.Legal_Guardian_Relationship__c") == '' ||
        component.get("v.lCase.Legal_Guardian_Phone__c") == undefined || component.get("v.lCase.Legal_Guardian_Phone__c") == '' ||
        component.get("v.lCase.Legal_Guardian_Email__c") == undefined || component.get("v.lCase.Legal_Guardian_Email__c") == '' ||
        component.get("v.alternateContactObj.lgconfirmEmail") == undefined || component.get("v.alternateContactObj.lgconfirmEmail") == '') 
        ){
            helper.showToast(component,event,'The enrolling patient is a minor. A parent or guardian will need to complete this page.','Warning');
        }else if(component.get("v.lCase.Legal_Guardian_Email__c") != undefined && component.get("v.lCase.Legal_Guardian_Email__c") != '' && !component.get("v.lCase.Legal_Guardian_Email__c").match(emailPattern)){
        	helper.showToast(component,event,'Email format is incorrect, Please enter valid email address.','Warning');
    	}else if(component.get("v.alternateContactObj.lgconfirmEmail") != undefined && component.get("v.alternateContactObj.lgconfirmEmail") != '' && !component.get("v.alternateContactObj.lgconfirmEmail").match(emailPattern)){
        	helper.showToast(component,event,'Confirm Email format is incorrect, Please enter valid confirm email address.','Warning');
   		}else if(component.get("v.lCase.Legal_Guardian_Email__c") != undefined && component.get("v.lCase.Legal_Guardian_Email__c") != '' && 
            component.get("v.alternateContactObj.lgconfirmEmail") != undefined && component.get("v.alternateContactObj.lgconfirmEmail") != '' && 
            component.get("v.lCase.Legal_Guardian_Email__c") != component.get("v.alternateContactObj.lgconfirmEmail")){
        	helper.showToast(component,event,'Email and Confirm Email are not matching, Please enter valid confirm email address.','Warning');
        }else if(component.get("v.lCase.Legal_Guardian_Phone__c") != undefined && component.get("v.lCase.Legal_Guardian_Phone__c") != '' && (!component.get("v.lCase.Legal_Guardian_Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.lCase.Legal_Guardian_Phone__c").match(alphaPattern))){
            helper.showToast(component,event,'Please enter valid legal guardian phone.','Warning'); 
        }else if(component.get("v.lCase.Emergency_Contact_Phone__c") != undefined && component.get("v.lCase.Emergency_Contact_Phone__c") != '' && (!component.get("v.lCase.Emergency_Contact_Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.lCase.Emergency_Contact_Phone__c").match(alphaPattern))){
            helper.showToast(component,event,'Please enter valid emergency contact phone.','Warning'); 
        }else{
            if(component.get("v.alternateContactObj.lgfirstName") != undefined && component.get("v.alternateContactObj.lgfirstName") != '' 
            && component.get("v.alternateContactObj.lglastName") != undefined  && component.get("v.alternateContactObj.lglastName") != '' ){
                component.set("v.lCase.Legal_Guardian_Name__c",component.get("v.alternateContactObj.lgfirstName")+' '+component.get("v.alternateContactObj.lglastName"));
            }
            if(component.get("v.alternateContactObj.emergencyContactFirstName") != undefined && component.get("v.alternateContactObj.emergencyContactFirstName") != '' 
            && component.get("v.alternateContactObj.emergencyContactLastName") != undefined  && component.get("v.alternateContactObj.emergencyContactLastName") != '' ){
                component.set("v.lCase.Emergency_Contact_Name__c",component.get("v.alternateContactObj.emergencyContactFirstName")+' '+component.get("v.alternateContactObj.emergencyContactLastName"));
            }
         
         	helper.handleNextButton(component,event); 
        }
    },
    handleRefresh: function(component, event, helper) {
       helper.handleRefresh(component,event);  
    },
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'ShowAlternateContactInformationScreen');
    },
    
    formatLegalPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("lphone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.acphonesize",phoneNumber.length);
        }else{
            component.set("v.acphonesize",15);  
        }
        
    },
    
    formatEmergencyPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("ePhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
       
        if(s.length >= 10){
            component.set("v.emphonesize",phoneNumber.length);
        }else{
            component.set("v.emphonesize",15);  
        }
        
    },

})