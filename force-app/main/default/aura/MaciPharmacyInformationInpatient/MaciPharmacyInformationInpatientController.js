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
        }else if(component.get("v.newCase.Inpatient_Pharmacy_Type__c") == '' || component.get("v.newCase.Inpatient_Pharmacy_Type__c") == undefined ){
            helper.showToast(component,event,'Please fill Inpatient Pharmacy Type.','Warning'); 
        }else if(component.get("v.newCase.Inpatient_Pharmacy_Type__c") != '' && component.get("v.newCase.Inpatient_Pharmacy_Type__c") != undefined && component.get("v.newCase.Inpatient_Pharmacy_Type__c") == 'Other' && (component.get("v.newCase.Other__c") == '' || component.get("v.newCase.Other__c") == undefined)){
            helper.showToast(component,event,'Please fill Other.','Warning'); 
        }else if(component.get("v.pharmacistInfo.Title__c") == '' || component.get("v.pharmacistInfo.Title__c") == undefined ){
            helper.showToast(component,event,'Please fill Inpatient Pharmacist Position/Title.','Warning'); 
        }else if(component.get("v.pharmacistInfo.Title__c") != '' && component.get("v.pharmacistInfo.Title__c") != undefined && component.get("v.pharmacistInfo.Title__c") == 'Other title' && (component.get("v.pharmacistInfo.Other_Title__c") == '' || component.get("v.pharmacistInfo.Other_Title__c") == undefined)){
            helper.showToast(component,event,'Please fill Other title.','Warning'); 
        }
    	else{
            helper.handleNextButton(component,event); 
            component.set("v.ShowSpinner",true);
        }
 
    },
    
    handlePharmacyTypeOnChange : function(component, event, helper) {
        var ptype =$("#pharmacyType").val();
        component.set("v.newCase.Inpatient_Pharmacy_Type__c",ptype);
    },
    
    handleTitleOnChange : function(component, event, helper) {
        var title =$("#title").val();
        component.set("v.pharmacistInfo.Title__c",title);
    },
})