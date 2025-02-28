({  
    doInit : function(component, event, helper) {
        helper.handleInit(component, event);
    },
    
	navigateToMangePatientsPage : function(component, event, helper) {
        var prescriberStatus = component.get("v.cAccount.US_WSREMS__Status__c"); 
        if(prescriberStatus != 'Certified'){
            helper.showToast(component,event,$A.get("$Label.c.Maci_Manage_Patients_Restricted_Message") ,'Warning');
        }else{
		   //Navigate to Prescriber Page
			var nav = component.find("navigation");
			var pageReference = {
				type: "comm__namedPage",
				attributes: {
					pageName: 'manage-patients'
				}
			};
			nav.navigate( pageReference ); 
		}
	},
    
     navigateToPrescriberPreferencePage : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'prescriberpreferences'
        }
        };
        nav.navigate( pageReference );

    },
    
    
    downloadEnrollmentForm: function(component, event, helper) {
            var action = component.get("c.getPrescriberEnrollmentForm");
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