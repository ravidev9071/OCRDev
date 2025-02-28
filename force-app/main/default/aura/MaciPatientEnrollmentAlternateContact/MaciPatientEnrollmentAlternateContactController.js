({
	handleNext: function(component,event,helper){

        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var alphaPattern = /[a-zA-Z]/g;

        if(component.get("v.alternateContactObj.emergencyContactRelationship") != undefined || component.get("v.alternateContactObj.emergencyContactRelationship") != ''){
            component.set("v.pCase.Emergency_Contact_Relationship__c",component.get("v.alternateContactObj.emergencyContactRelationship"));
        }
        
        if(component.get("v.alternateContactObj.emergencyContactPhoneNum") != undefined && component.get("v.alternateContactObj.emergencyContactPhoneNum") != '' ){
            component.set("v.pCase.Emergency_Contact_Phone__c",component.get("v.alternateContactObj.emergencyContactPhoneNum"));
        }
        
        if(component.get("v.pCase.Emergency_Contact_Phone__c") != undefined && component.get("v.pCase.Emergency_Contact_Phone__c") != '' && (!component.get("v.pCase.Emergency_Contact_Phone__c").replace(/[^0-9]+/g, "").match(numberpattern) || component.get("v.pCase.Emergency_Contact_Phone__c").match(alphaPattern))){
            helper.showToast(component,event,'Please enter valid emergency contact phone.','Warning'); 
        }else{
            if(component.get("v.alternateContactObj.emergencyContactFirstName") != undefined && component.get("v.alternateContactObj.emergencyContactFirstName") != '' 
            && component.get("v.alternateContactObj.emergencyContactLastName") != undefined  && component.get("v.alternateContactObj.emergencyContactLastName") != '' ){
                component.set("v.pCase.Emergency_Contact_Name__c",component.get("v.alternateContactObj.emergencyContactFirstName")+' '+component.get("v.alternateContactObj.emergencyContactLastName"));
            }
         
         helper.handleNextButton(component,event); 
        }
    },
    handleRefresh: function(component, event, helper) {
        helper.handleRefresh(component,event);  
    },
     handlePrescriberRefresh: function(component, event, helper) {
       helper.handlePrescriberRefresh(component,event);  
    },
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'ShowPatientInformation');
    },
      handlePrescriberPrevious : function(component,event,helper){
        helper.firePrescriberEvent(component,event,'ShowPatientInformationScreen');
    },
    formatPhoneNumber: function(component, helper, event) {
        var phoneNo = component.find("ePhone");
        var phoneNumber = phoneNo.get('v.value');
        var s = (phoneNumber).replace(/[^0-9]+/g, "");
        
        if(s.length >= 10){
            component.set("v.ephonesize",phoneNumber.length);
        }else{
            component.set("v.ephonesize",15);  
        }
        
    },
})