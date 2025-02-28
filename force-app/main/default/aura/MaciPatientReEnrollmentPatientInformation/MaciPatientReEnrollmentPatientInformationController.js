({  
    doInit : function(component, event, helper) {
        if(component.get("v.newCase.Best_time_to_call__c") == 'Morning'){
        	component.set("v.morning",true);
        }else if(component.get("v.newCase.Best_time_to_call__c") == 'Afternoon'){  
        	component.set("v.afternoon",true);
        }else if(component.get("v.newCase.Best_time_to_call__c") == 'Evening'){   
        	component.set("v.evening",true);
        }
        
    },
	handleNext: function(component,event,helper){
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;
        var today = new Date();
        var birthDate = new Date(component.get("v.reCase.US_WSREMS__DOB__c"));
                    
        if(component.get("v.reCase.US_WSREMS__First_Name__c") == undefined || component.get("v.reCase.US_WSREMS__First_Name__c") == '' ||
           component.get("v.reCase.US_WSREMS__Last_Name__c") == undefined || component.get("v.reCase.US_WSREMS__Last_Name__c") == '' ||
           component.get("v.newCase.SYN_Street_Address__c") == undefined || component.get("v.newCase.SYN_Street_Address__c") == '' ||
           component.get("v.newCase.US_WSREMS__City__c") == undefined || component.get("v.newCase.US_WSREMS__City__c") == '' ||
           component.get("v.newCase.US_WSREMS__State__c") == undefined || component.get("v.newCase.US_WSREMS__State__c") == '' ||
           component.get("v.newCase.SYN_Zip_Code__c") == undefined || component.get("v.newCase.SYN_Zip_Code__c") == '' ||
           component.get("v.reCase.US_WSREMS__DOB__c") == undefined || component.get("v.reCase.US_WSREMS__DOB__c") == '' ||
           
           component.get("v.newCase.US_WSREMS__Email__c") == undefined || component.get("v.newCase.US_WSREMS__Email__c") == '' ||
           component.get("v.confirmEmail") == undefined || component.get("v.confirmEmail") == '' ||
           component.get("v.newCase.US_WSREMS__Phone__c") == undefined || component.get("v.newCase.US_WSREMS__Phone__c") == '' ){
        	 helper.showToast(component,event,'Please fill Name, Address, Date of Birth, Email and Primary Phone.','Warning');
        }else if(!component.get("v.newCase.US_WSREMS__Email__c").match(emailPattern)){
        	helper.showToast(component,event,'Email format is incorrect, Please enter valid email address.','Warning');
    	}else if(!component.get("v.confirmEmail").match(emailPattern)){
        	helper.showToast(component,event,'Confirm Email format is incorrect, Please enter valid confirm email address.','Warning');
   		}else if(component.get("v.newCase.US_WSREMS__Email__c") != component.get("v.confirmEmail")){
        	helper.showToast(component,event,'Email and Confirm Email are not matching, Please enter valid confirm email address.','Warning');
        }else if(component.get("v.newCase.US_WSREMS__Phone__c") != undefined && component.get("v.newCase.US_WSREMS__Phone__c") != '' && (!component.get("v.newCase.US_WSREMS__Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.US_WSREMS__Phone__c").match(alphaPattern))){
           helper.showToast(component,event,'Please enter valid Primary Phone.','Warning'); 
        }else if(component.get("v.newCase.SYN_Alternate_Phone__c") != undefined && component.get("v.newCase.SYN_Alternate_Phone__c") != '' && component.get("v.newCase.SYN_Alternate_Phone__c") != ' ' && (!component.get("v.newCase.SYN_Alternate_Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.newCase.SYN_Alternate_Phone__c").match(alphaPattern))){
           helper.showToast(component,event,'Please enter valid Alternate Phone.','Warning'); 
        }else if(!component.get("v.newCase.SYN_Zip_Code__c").match(zipcodepattern)){
            helper.showToast(component,event,'Please enter valid Zip Code.','Warning'); 
        }else if(birthDate > today){
            helper.showToast(component,event,'Date of Birth can not be in the future.','Warning');  
        }else{

            var patientage = helper.calculate_age(component, event,new Date(component.get("v.newCase.US_WSREMS__DOB__c")));
            if(patientage < 18){
            	component.set("v.isPatientMinor",true);
            }
         	helper.handleNextButton(component, event);
        }
        
    },
    handleRefresh: function(component, event, helper) {
        component.set("v.morning",false);
        component.set("v.afternoon",false);
        component.set("v.evening",false);
        component.set("v.newCase.Best_time_to_call__c","");
       helper.handleRefresh(component,event);  
    },
    
    handlePrevious : function(component,event,helper){
       //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'manage-patients'
            }
        };
        nav.navigate( pageReference ); 
    },
    
    handleStateOnChange : function(component, event, helper) {
        //var primaryState = component.get("v.pCase.US_WSREMS__State__c");  
        var primaryState =$("#primaryState").val();
        component.set("v.newCase.US_WSREMS__State__c",primaryState);

    },
    
    morningSelect : function(component, event, helper) {
        component.set("v.morning",true);
        component.set("v.afternoon",false);
        component.set("v.evening",false);
        component.set("v.newCase.Best_time_to_call__c",'Morning');
    },
    
    afternoonSelect : function(component, event, helper) {
         component.set("v.morning",false);
        component.set("v.afternoon",true);
        component.set("v.evening",false);
        component.set("v.newCase.Best_time_to_call__c",'Afternoon');
    },
    
    eveningSelect : function(component, event, helper) {
        component.set("v.morning",false);
        component.set("v.afternoon",false);
        component.set("v.evening",true);
        component.set("v.newCase.Best_time_to_call__c",'Evening');
    },
    
    formatPrimaryNumber: function(component, helper, event) {
        var phoneNo = component.find("pPhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.pphonesize",phoneNumber.length);
        }else{
            component.set("v.pphonesize",15);  
        }
        
    },
    
    formatAlternateNumber: function(component, helper, event) {
        var phoneNo = component.find("aPhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.aphonesize",phoneNumber.length);
        }else{
            component.set("v.aphonesize",15);  
        }
        
    },
    
    
})