({
    doInit : function(component, event, helper) {
        helper.handleInit(component, event);
        component.set('v.ShowSpinner', true);
        var url_string = document.location.href;
        var url = new URL(url_string);         
        var patientURLId = url.searchParams.get("PatientID");
        component.set("v.patientID",patientURLId);
    },
    
    	handleComplete: function(component,event,helper){
            debugger;
        var FemalesofReproductivePotential =$("#Females-of-Reproductive-Potential").is(':checked');
        var PrepubertalFemal =$("#PrepubertalFemal").is(':checked');
        var PostmenopausalFemale =$("#PostmenopausalFemale").is(':checked');
        var Othermedical  =$("#Othermedical").is(':checked');
        var Physiological =$("#Physiological").is(':checked');
        var MedicalSurgical =$("#MedicalSurgical").is(':checked');
        var Other =$("#Other").is(':checked');
        var PleaseSpecify =component.get("v.rCase.Please_specify__c"); 
        var AnnualVerify =$("#AnnualVerify").is(':checked'); 
var AnnualVerifycheck = component.get("v.patRiskCat") ;
       if(FemalesofReproductivePotential ==true){
        component.set("v.patRiskCatNew","Female of Reproductive Potential (FRP)");
       }
       if(PrepubertalFemal ==true){
        component.set("v.patRiskCatNew","FNRP (Patient is pre-pubertal)");
       }
       if(PostmenopausalFemale ==true){
        component.set("v.patRiskCatNew","FNRP (Patient is post-menopausal)");
       }
       if(Othermedical ==true){
        component.set("v.patRiskCatNew","FNRP (other medical reasons for permanent irreversible infertility)");
       }
        if(FemalesofReproductivePotential == false && PrepubertalFemal == false && PostmenopausalFemale == false && Othermedical == false){
            helper.showToast(component,event,'Please Select Females of Reproductive Potential/Females of Non-Reproductive Potential.','Warning');
        }else if((Physiological == false && MedicalSurgical == false && Other == false) && ( component.get("v.patRiskCatNew") != component.get("v.patRiskCat"))){
            helper.showToast(component,event,'Please Select Reason for change in classification.','Warning');
        }else if((MedicalSurgical == true || Other == true) && PleaseSpecify == undefined){
            helper.showToast(component,event,'Please Specify Must be Filled.','Warning');
        }else if(PrepubertalFemal == true && AnnualVerifycheck == 'FNRP (Patient is pre-pubertal)' && AnnualVerify == false){
            helper.showToast(component,event,'Please Select Annual verification.','Warning');
        }else{
            component.set("v.ShowSpinner",true);

              component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c",component.get("v.patRiskCatNew")); 
            console.log('patriskcat'+component.get("v.rCase.US_WSREMS__Patient_Risk_Category__c"));

            helper.createChangeReproductiveStatusCase(component,event); 
        }
    },
    
    FemaleOfReproductivePotentialSelect : function(component, event, helper) {
        
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","Female of Reproductive Potential (FRP)");
        component.set("v.PrepubertalFemaleValue",false);
        component.set("v.PostmenopausalFemaleValue",false);
        component.set("v.OtherMedicalValue",false);
        component.set("v.annualCheck",false);
         $("[id$=AnnualVerify]").attr("disabled",true);
    },

    PrepubertalFemaleSelect : function(component, event, helper) {
            
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","FNRP (Patient is pre-pubertal)");
component.set("v.patRiskCatNew","FNRP (Patient is pre-pubertal)");
        component.set("v.FemalesofReproductivePotentialValue",false);
        component.set("v.PostmenopausalFemaleValue",false);
        component.set("v.OtherMedicalValue",false);
         $("[id$=AnnualVerify]").attr("disabled",false);
    },

    PostmenopausalFemaleSelect : function(component, event, helper) {
       
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","FNRP (Patient is post-menopausal)");
component.set("v.patRiskCatNew","FNRP (Patient is post-menopausal)");
        component.set("v.FemalesofReproductivePotentialValue",false);
        component.set("v.PrepubertalFemaleValue",false);
        component.set("v.OtherMedicalValue",false);
        component.set("v.annualCheck",false);
        $("[id$=AnnualVerify]").attr("disabled",true);
    },

    OtherMedicalSelect : function(component, event, helper) {
        
        
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","FNRP (other medical reasons for permanent irreversible infertility)");
component.set("v.patRiskCatNew","FNRP (other medical reasons for permanent irreversible infertility)");
        component.set("v.PrepubertalFemaleValue",false);
        component.set("v.PostmenopausalFemaleValue",false);
        component.set("v.FemalesofReproductivePotentialValue",false);
        component.set("v.annualCheck",false);
        $("[id$=AnnualVerify]").attr("disabled",true);
        
    },
    
    
    PhysiologicalSelect : function(component, event, helper) {
        component.set("v.rCase.Reason_for_change_in_classification__c","Physiological transition");  
    },
    
    MedicalSurgicalSelect : function(component, event, helper) {
        component.set("v.rCase.Reason_for_change_in_classification__c","Medical/surgical");
    },
    
    OtherSelect : function(component, event, helper) {
        component.set("v.rCase.Reason_for_change_in_classification__c","Other");
    },
	
    annualSelect : function(component, event, helper) {
        var annualVerify =$("#AnnualVerify").is(':checked');
        if(annualVerify == true){
            component.set("v.annualCheck",true);
			component.set("v.rCase.Annual_Verification__c",true);
        }else{
			component.set("v.rCase.Annual_Verification__c",false);
		}
    }
})