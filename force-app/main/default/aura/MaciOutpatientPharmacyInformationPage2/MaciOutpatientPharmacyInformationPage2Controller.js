({
	handleStateOnChange : function(component, event, helper) {
       
        var primaryState =$("#primaryState").val();
        component.set("v.newCase.State_Secondary_Office__c",primaryState);
    },
    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'PharmCMailingAddressScreen'); 
    },
     handleNext: function(component,event,helper){
        var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        if(  component.get("v.newCase.Address_1_Secondary_Office__c") == undefined 
           || component.get("v.newCase.City_Secondary_Office__c") == undefined || component.get("v.newCase.SYN_Zip_Code__c") == undefined 
           || component.get("v.newCase.State_Secondary_Office__c") == undefined || component.get("v.newCase.Phone_Secondary_Office__c") == undefined  
           || component.get("v.newCase.Fax_Secondary_Office__c") == undefined ||component.get("v.newCase.Address_1_Secondary_Office__c") == ''
           || component.get("v.newCase.City_Secondary_Office__c") == '' || component.get("v.newCase.SYN_Zip_Code__c") == '' 
           || component.get("v.newCase.State_Secondary_Office__c") == '' || component.get("v.newCase.Phone_Secondary_Office__c") == '' 
           || component.get("v.newCase.Fax_Secondary_Office__c") == '')
        {
           helper.showToast(component,event,'All fields are required.','Warning');
        }else if(!component.get("v.newCase.Phone_Secondary_Office__c").match(numberpattern)){
           helper.showToast(component,event,'Please enter valid phone.','Warning'); 
        }else if(!component.get("v.newCase.Fax_Secondary_Office__c").match(numberpattern)){
           helper.showToast(component,event,'Please enter valid Fax.','Warning'); 
        }else if(!component.get("v.newCase.SYN_Zip_Code__c").match(zipcodepattern)){
           helper.showToast(component,event,'Please enter valid Zip Code.','Warning'); 
        }else{
            helper.handleNextButton(component,event,helper);
        }
    },
})