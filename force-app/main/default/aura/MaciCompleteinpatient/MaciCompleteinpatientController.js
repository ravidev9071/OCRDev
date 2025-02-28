({
	doInit : function(component, event, helper) {
        helper.handleInit(component, event);
    },
    
     navigateToMangePharmacyPage : function(component, event, helper) {
            //Navigate to Prescriber Page
            var nav = component.find("navigation");
            var pageReference = {
            type: "comm__namedPage",
            attributes: {
                pageName: 'inpatient-manage-pharmacy'
            }
            };
            nav.navigate( pageReference );
        
	},
    
    navigateToPreferencePage : function(component, event, helper) {
        //Navigate to Inpatient Pharmacy Prefernce Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'inpatientpreferences'
        }
        };
        nav.navigate( pageReference );
        
	},

    downloadEnrollmentPage :function(component, event, helper) {
         var action = component.get("c.getInPatientPharmacyEnrollmentForm");
		 action.setParams({
            recordId :component.get("v.Pharmacyacc")
               
        });
            action.setCallback(this, result => {
            if(result.getState() === 'SUCCESS') {
            let downloadLink = document.createElement('a');
            downloadLink.download = 'Enrollment Form.pdf';
            downloadLink.href = 'data:application/pdf;base64,'+result.getReturnValue();
            downloadLink.click();
			helper.addAttachment(component, event);
            } else {
                helper.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
            }
            });
            $A.enqueueAction(action);
    },
})