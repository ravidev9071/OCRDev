({
	doInit : function(component, event, helper) {
        helper.handleInit(component, event);
        component.set('v.isLoading', true);
        helper.fetchResources(component,event);
        
    },
    
    navigateToPatientEnrollmentPage : function(component, event, helper) {
       var prescriberStatus = component.get("v.cAccount.US_WSREMS__Status__c"); 
       if(prescriberStatus != 'Active'){
        helper.showToast(component,event,$A.get("$Label.c.Maci_Manage_Patients_Restricted_Message") ,'Warning');
       }else{
       //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'office-contact-enrolls-patient'
            }
        };
        nav.navigate( pageReference ); 
        }
	},
    
     navigateToMonthlyPregancyTestPage : function(component, event, helper) {
        
       //Navigate to navigateToPharmacyCertify Page
        var nav = component.find("navigation");
        var recordId = event.currentTarget.getAttribute('data-id');
        component.set("v.recordId", recordId);
        
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'monthly-test-oc'
            },
                state: {
                PatientID:component.get("v.recordId")
           }
        };
        nav.navigate( pageReference ); 
	},
    
    navigateToModalPopUp : function(component, event, helper) {
        var recordId = event.currentTarget.getAttribute('data-id');
      
        component.set("v.sendEmailToPrescriber", recordId);
        helper.fetchCaseDetails(component,recordId);
        component.set("v.isModalOpen", true); 
        var modalvalue=component.get("v.isModalOpen");
        
        
    },
    navigateToModalPopUpForPatient : function(component, event, helper) {
       
        var recordId = event.currentTarget.getAttribute('data-id'); 

        component.set("v.sendEmailToPrescriber", recordId);
        helper.fetchCaseDetails(component,recordId);
        component.set("v.isModalPatientOpen", true); 
        var modalvalue=component.get("v.isModalPatientOpen");
        
        
    },
     SendEmailToPrescriber : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        var recId = component.get("v.sendEmailToPrescriber");
         let templateName=$A.get("$Label.c.Prescriber_Signature_Email_From_Portal");
        var action = component.get("c.sendEmailToPresciberForSignature"); 
        action.setParams({
            caseId : recId,
            templateName:templateName,
            personAccount:'Prescriber'
        });
          component.set('v.isLoading', true); 
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            var state = response.getState();
             
            if (state === "SUCCESS"){
               
                   
                    helper.showToast(component,event,'Sent Email successfully.','Success');
                 component.set('v.isLoading', false); 
                    

               
            }else{
                helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
            }
        });
          $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action); 
        
    },
 
    SendEmailToPatient : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        var recId = component.get("v.sendEmailToPrescriber");
         let templateName=$A.get("$Label.c.Patient_Signature_Email_From_Portal");
        var action = component.get("c.sendEmailToPresciberForSignature"); 
        action.setParams({
            caseId : recId,
            templateName:templateName,
            personAccount:'Patient'
        });
        action.setCallback(this, function(response) {
            let result = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS"){
                    helper.showToast(component,event,'Sent Email successfully.','Success');
               
            }else{
                helper.showToast(component,event,'Something went wrong, please contact system admin.','Error');
            }
        });
         $A.get('e.force:refreshView').fire();
        $A.enqueueAction(action); 
        
    },
    closeModel : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    closeModelPatient : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalPatientOpen", false);
    },
     navigateToReproductivePotentialStatusPage : function(component, event, helper) {
        
       //Navigate to navigateToPharmacyCertify Page
        var nav = component.find("navigation");
        component.set("v.recordId", event.currentTarget.dataset.id);
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'productive-potential-status'
            },
                state: {
                PatientID:component.get("v.recordId")
           }
        };
        nav.navigate( pageReference ); 
	},
    
     navigateToDisenrollPatientPage : function(component, event, helper) {
        var nav = component.find("navigation");
         component.set("v.recordId", event.currentTarget.dataset.id);
         
       //Navigate to navigateToPharmacyCertify Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'disenroll-patient'
            },
            state: {
                id:component.get("v.recordId")
            }
        };
        nav.navigate( pageReference ); 
	},
    
    
    
     navigateToManageOfficePage : function(component, event, helper) {
        
       //Navigate to navigate to manage-office Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'manage-office'
            } 
            
        };
        nav.navigate( pageReference ); 
	},
    
     navigateToPatientDetailPage : function(component, event, helper) {
        debugger;
       //Navigate to navigateToPharmacyCertify Page
        
         var nav = component.find("navigation");
         component.set("v.recordId", event.currentTarget.dataset.id);
         component.set("v.patientRiskCategory", event.currentTarget.dataset.us_wsrems__patient_risk_category__c);
        
      
         var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'patient-information'
            },
             state: {
                 csId: component.get("v.recordId"),
                 oc: true
             }
        };
        nav.navigate( pageReference ); 
	},
    
    onNext: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber + 1);
        helper.setPageDataAsPerPagination(component);
    },
     
    onPrev: function(component, event, helper) {        
        let pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber - 1);
        helper.setPageDataAsPerPagination(component);
    },
    
    navigateToReEnrollPatientPage : function(component, event, helper) {
        component.set("v.recordId", event.currentTarget.dataset.id);
       //Navigate to navigateToPharmacyCertify Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'reenrollmentform'
            },
             state: {
                 id:component.get("v.recordId")
             }
        };
        nav.navigate( pageReference ); 
	},
       sortByPrescriberUp: function(component,event, helper) {
        component.set('v.sortDirection', 'asc');
        component.set('v.sortedBy', 'SYN_Prescriber__r.Name');
        helper.handleSort(component, 'SYN_Prescriber__r.Name'); 
    },
    sortByPrescriberDown: function(component, event ,helper) {
        component.set('v.sortDirection', 'desc');
        component.set('v.sortedBy', 'SYN_Prescriber__r.Name');
        helper.handleSort(component, 'SYN_Prescriber__r.Name'); 
    },
    sortByPatientUp: function(component,event, helper) {
        component.set('v.sortDirection', 'asc');
        component.set('v.sortedBy', 'US_WSREMS__Patient__r.Name');
        helper.handleSort(component, 'US_WSREMS__Patient__r.Name'); 
    },
    sortByPatientDown: function(component,event, helper) {
        component.set('v.sortDirection', 'desc');
        component.set('v.sortedBy', 'US_WSREMS__Patient__r.Name');
        helper.handleSort(component, 'US_WSREMS__Patient__r.Name'); 
    },
    
    
})