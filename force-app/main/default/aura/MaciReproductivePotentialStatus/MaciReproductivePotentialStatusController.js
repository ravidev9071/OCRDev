({

    doInit : function(component, event, helper) {
        var racass = component.get("v.rCase");
        

        if(component.get("v.rCase.US_WSREMS__Patient_Risk_Category__c") == "Female of Reproductive Potential (FRP)"){
            component.set("v.FemalesofReproductivePotentialValue",true);
        }
        if(component.get("v.rCase.US_WSREMS__Patient_Risk_Category__c") == "FNRP (Patient is pre-pubertal)"){
            component.set("v.PrepubertalFemaleValue",true);
        }
        if(component.get("v.rCase.US_WSREMS__Patient_Risk_Category__c") == "FNRP (Patient is post-menopausal)"){
            component.set("v.PostmenopausalFemaleValue",true);
        }
        if(component.get("v.rCase.US_WSREMS__Patient_Risk_Category__c") == "FNRP (other medical reasons for permanent irreversible infertility)"){
            component.set("v.OtherMedicalValue",true);
        }

        if(component.get("v.rCase.Negative_Pregnancy_Test_Completed__c") == "Yes"){
            component.set("v.PregnancyYes",true);
        }
        if(component.get("v.rCase.Negative_Pregnancy_Test_Completed__c") == "No"){
            component.set("v.PregnancyNo",true);
        }

        if(component.get("v.rCase.SYN_Prescriber_Signature__c") == "Yes"){
            component.set("v.isCertify",true);
        }
    },
    handleCancel: function(component,event){
        component.set("v.isModalOpenRPS",false);
    },

	handleNext: function(component,event,helper){
        var FemalesofReproductivePotential =$("#Females-of-Reproductive-Potential").is(':checked');
        var PrepubertalFemal =$("#PrepubertalFemal").is(':checked');
        var PostmenopausalFemale =$("#PostmenopausalFemale").is(':checked');
        var Othermedical  =$("#Othermedical").is(':checked');
        var PregnancyTestYes =$("#PregnancyTestYes").is(':checked');
        var PregnancyTestNo =$("#PregnancyTestNo").is(':checked');
        var Certification =$("#Certification").is(':checked');
        if(FemalesofReproductivePotential == false && PrepubertalFemal == false && PostmenopausalFemale == false && Othermedical == false){
            helper.showToast(component,event,'Please Select Females of Reproductive Potential/Females of Non-Reproductive Potential.','Warning');
        }else if(FemalesofReproductivePotential == true && PregnancyTestYes == false && PregnancyTestNo == false){
            helper.showToast(component,event,'Please Select Pregnancy Test.','Warning');
        }else if((PrepubertalFemal == true || PostmenopausalFemale == true || Othermedical == true) && (PregnancyTestYes == true || PregnancyTestNo == true)){
            helper.showToast(component,event,'Pregnancy Test is not required.','Warning');
        }else if(Certification == false && component.get("v.isOfficeContact") == false){
            helper.showToast(component,event,'Please Select Certification.','Warning');
        }else{
            component.set("v.ShowSpinner",true);
            helper.handleNextButton(component,event); 
        }
    },

    handleRefresh: function(component, event, helper) {
       helper.handleRefresh(component,event);  
    },

    handlePrevious : function(component,event,helper){
        helper.fireEvent(component,event,'ShowAlternateContactInformation2');
    },
    handlePrescriberPrevious : function(component,event,helper){
        helper.fireEvent(component,event,'ShowAlternateContactInformationScr2');
    },

    FemaleOfReproductivePotentialSelect : function(component, event, helper) {
       
        $(":radio[name='flexRadioDefault']").attr("disabled",false);
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","Female of Reproductive Potential (FRP)");
        component.set("v.PrepubertalFemaleValue",false);
        component.set("v.PostmenopausalFemaleValue",false);
        component.set("v.OtherMedicalValue",false);
    },

    PrepubertalFemaleSelect : function(component, event, helper) {
        $('#PregnancyTestNo').prop('checked', false);
        $('#PregnancyTestYes').prop('checked', false);
        $(":radio[name='flexRadioDefault']").attr("disabled","disabled");
        
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","FNRP (Patient is pre-pubertal)");
        component.set("v.FemalesofReproductivePotentialValue",false);
        component.set("v.PostmenopausalFemaleValue",false);
        component.set("v.OtherMedicalValue",false);
        if(component.get("v.isFromOfficeContact")==true){
        component.set("v.rCase.Negative_Pregnancy_Test_Completed__c","");  
        }
    },

    PostmenopausalFemaleSelect : function(component, event, helper) {
        
        $('#PregnancyTestNo').prop('checked', false);
        $('#PregnancyTestYes').prop('checked', false);
        $(":radio[name='flexRadioDefault']").attr("disabled","disabled");
        
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","FNRP (Patient is post-menopausal)");
        component.set("v.FemalesofReproductivePotentialValue",false);
        component.set("v.PrepubertalFemaleValue",false);
        component.set("v.OtherMedicalValue",false);
          if(component.get("v.isFromOfficeContact")==true){
        component.set("v.rCase.Negative_Pregnancy_Test_Completed__c","");  
        }
    },

    OtherMedicalSelect : function(component, event, helper) {
        $('#PregnancyTestNo').prop('checked', false);
        $('#PregnancyTestYes').prop('checked', false);
        $(":radio[name='flexRadioDefault']").attr("disabled","disabled");
        
        component.set("v.rCase.US_WSREMS__Patient_Risk_Category__c","FNRP (other medical reasons for permanent irreversible infertility)");
        component.set("v.PrepubertalFemaleValue",false);
        component.set("v.PostmenopausalFemaleValue",false);
        component.set("v.FemalesofReproductivePotentialValue",false);
          if(component.get("v.isFromOfficeContact")==true){
        component.set("v.rCase.Negative_Pregnancy_Test_Completed__c","");  
        }
    },

    PregnancyYesSelect : function(component, event, helper) {
        component.set("v.rCase.Negative_Pregnancy_Test_Completed__c","Yes");  
        component.set("v.PregnancyNo",false);  
    },

    PregnancyNoSelect : function(component, event, helper) {
        component.set("v.rCase.Negative_Pregnancy_Test_Completed__c","No"); 
        component.set("v.PregnancyYes",false);  
    },

    CertifySelect : function(component, event, helper) {
        var Certification =$("#Certification").is(':checked');
        if(Certification == true && component.get("v.isOfficeContact") == false){
            component.set("v.rCase.SYN_Prescriber_Signature__c","Yes");
        }
        if(Certification == false){
            component.set("v.rCase.SYN_Prescriber_Signature__c","No");
        }
    },
})