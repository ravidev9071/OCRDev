({
	findProviderInfo: function(component,event,helper){
        
        var npi = component.get("v.newCase.US_WSREMS__NPI__c");
        var numberpattern = /^(\s*\d\s*){10}$/;
        if(npi == '' || npi == undefined){
            helper.showToast(component,event,'Please fill valid NPI.','Warning');
        }else if(npi.length <10){
            helper.showToast(component,event,'Pharmacy NPI should be 10 digits.','Warning');
        }else if(!npi.match(numberpattern)){
             helper.showToast(component,event,'Pharmacy NPI should contain 10 digits.','Warning');
        }else{
             component.set("v.ShowSpinner",true);
             helper.getProviderDetails(component,event,helper);
        }
    },
     handleChange: function(component,event,helper){
         component.set("v.newCase.US_WSREMS__Name__c",'');
         //Mailing address....
         component.set("v.newCase.US_WSREMS__Address_Line_1__c",'');
         component.set("v.newCase.US_WSREMS__City__c",'');
         component.set("v.newCase.US_WSREMS__State__c",'');
         component.set("v.newCase.US_WSREMS__REMS_Zip_Code__c",'');
         component.set('v.ShowNPIInfo',false);
    },
    handleNext: function(component,event,helper){
        
		var numberpattern = /^(\s*\d\s*){10}$/;
        var emailPattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var zipcodepattern = /(^\d{5}$)|(^\d{5}-\d{4}$)/;
        var npi = component.get("v.newCase.US_WSREMS__NPI__c");
        var pharmName = component.get("v.newCase.US_WSREMS__Name__c");
        if(npi == '' || npi == undefined){
           helper.showToast(component,event,'Please fill valid NPI.','Warning');
        }else if(npi.length <10){
            helper.showToast(component,event,'Pharmacy NPI should be 10 digits.','Warning');
        }else if(!npi.match(numberpattern)){
             helper.showToast(component,event,'Pharmacy NPI should contain 10 digits.','Warning');
        }else if(pharmName == '' || pharmName == undefined){
             helper.showToast(component,event,'Pharmacy Name is required.','Warning');
        }
    else{
            helper.handleNextButton(component,event); 
            component.set("v.ShowSpinner",true);
        }
 
    },
    
})