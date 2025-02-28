({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        var url_string = document.location.href;
        var url = new URL(url_string);         
        var isOfficeContact = false;
        isOfficeContact = url.searchParams.get("oc");
        var recordId = url.searchParams.get("id");
        var csId = url.searchParams.get("csId");
        component.set("v.caseId", csId);
        component.set("v.patientID",recordId);
        component.set("v.isOfficeContact", isOfficeContact);
        helper.handleInit(component, event);
        
        
        var url_string = document.location.href;
        var url = new URL(url_string);         
        var patientRiskCategory = url.searchParams.get("PatientRiskCategory");
        helper.fetchResources(component,event);
    },
    
    navigateToPatientDetailPage : function(component, event, helper) {
        
        //Navigate to Prescriber Page
        var navEvt = $A.get("e.force:navigateToSObject");
        var patientAccount= component.get("v.patientID");
        
        navEvt.setParams({
            "recordId": patientAccount
        });
        navEvt.fire();
        
    },
    
    downloadPatientEnrollmentForm : function(component, event, helper) {
        var action = component.get("c.getPatientEnrollmentForm");
        action.setParams({
            recordId :event.currentTarget.dataset.id 
        });
        action.setCallback(this, result => {
            if(result.getState() === 'SUCCESS') {
            let downloadLink = document.createElement('a');
            downloadLink.download = 'Patient Enrollment Form.pdf';
            downloadLink.href = 'data:application/pdf;base64,'+result.getReturnValue();
            downloadLink.click();
            } else {
            helper.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
           }
          });
         $A.enqueueAction(action);
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
        
        navigateToMonthlyPregancyTestPage: function(component, event, helper) {
        // Get the navigation service
        var nav = component.find("navigation");
      
        // Determine the page to navigate to based on the oc parameter
        var pageName = component.get("v.isOfficeContact") ? 'monthly-test-oc' : 'monthly-test';
        
        // Create the pageReference object for navigation
        var newPageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: pageName
            },
                state: {
                PatientID: component.get("v.patientID")
           }
        };

        // Navigate to the specified page
        nav.navigate(newPageReference); 
	},
        
        navigateToProductivePotentialStatusPage : function(component, event, helper) {
        //Navigate to Maci Productive Potential Status Page
        var nav = component.find("navigation");
        
        var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'productive-potential-status'
            },
                state: {
                PatientID:component.get("v.patientID")
           }
        };
        nav.navigate( pageReference ); 
	}
})