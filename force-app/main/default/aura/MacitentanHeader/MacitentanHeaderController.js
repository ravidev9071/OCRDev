({
    getActiveTabName : function(component, event, helper) {
   		
        helper.getCurrentUserType(component);
        var pagename = window.document.title;
        var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
        if(isMaciProgramLive == 'No'){   
            component.set('v.showPreLaunchTab', true);
            if(pagename == 'Home'){
                component.set('v.showPreLaunchModal', true);
            }else{
                component.set('v.showPreLaunchModal', false);
            }
        }else{
            component.set('v.showPreLaunchTab', false);
    		component.set('v.showPreLaunchModal', false);
        }
        
        if(pagename != '' && pagename != undefined){
           var pname = pagename.toLowerCase();
           var tabId = component.find(pname);
            if(tabId != '' && tabId != undefined){
                $A.util.addClass(tabId, 'active'); 
            }
       }
       
        
        
        
    },
    
    logout : function(component, event, helper) {
       
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        baseURL + "/secur/logout.jsp";
        $A.get('e.force:logout').fire();
        var nav = component.find("navigation");
         var pageReference = {
             type: "comm__namedPage",
             attributes: {
                 pageName: 'login'
             }
         };
         nav.navigate( pageReference ); 
         
    },
    
    navigateToProfile : function(component, event, helper) {
       //Navigate to Creation Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                pageName: "profile",
                recordId: $A.get("$SObjectType.CurrentUser.Id"),
                actionName: "view"
            }
        };
        nav.navigate( pageReference );
    },

    navigateToManagePatientPage : function(component, event, helper) {
        var prescriberStatus = component.get("v.currentUser.Account.US_WSREMS__Status__c"); 
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

     navigateToManagePatientOfficeContactPage : function(component, event, helper) {
        var prescriberStatus = component.get("v.currentUser.Account.US_WSREMS__Status__c"); 
        if(prescriberStatus != 'Active'){
         helper.showToast(component,event,$A.get("$Label.c.Maci_Manage_Patients_Restricted_Message") ,'Warning');
        }else{
        //Navigate to Office Contact Page
         var nav = component.find("navigation");
         var pageReference = {
             type: "comm__namedPage",
             attributes: {
                 pageName: 'officecontacthome'
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
    
    //office contact 
   navigateToOfficeContactPreferencePage : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'maciofficecontactpreferences'
        }
        };
        nav.navigate( pageReference );

    },  
    navigateToInpatientPharmacyPreferencePage : function(component, event, helper) {
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

     navigateToOutpatientPharmacyPreferencePage : function(component, event, helper) {
        //Navigate to Inpatient Pharmacy Prefernce Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'outpatientpreferences'
        }
        };
        nav.navigate( pageReference );

    },

    navigateToPreferencePage : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var preferencepage = 'detail/'+userId;
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "standard__recordPage",
        attributes: {
            'objectApiName': 'User',
            'recordId': userId,
            'actionName': 'view'
        }
        };
        nav.navigate( pageReference );

    },

    navigateToMangePharmacyPage : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'pharmacy-manage-home'
        }
        };
        nav.navigate( pageReference );
    
    },

    
    navigateToInPatientMangePharmacyPage : function(component, event, helper) {
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

    navigateToInpatientSwitchPharmacyPage : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'inpatientswitchpharmacy'
        }
        };
        nav.navigate( pageReference );
    
    },
    
    navigateToSwitchPharmacyPage : function(component, event, helper) {
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'switchpharmacy'
        }
        };
        nav.navigate( pageReference );
    
    },

    downloadInPatientPharmayEnrollmentForm : function(component, event, helper) {
        component.set('v.ShowSpinner', true);
        var action = component.get("c.getInPatientPharmacyEnrollmentForm");
        action.setParams({
            recordId :component.get("v.Pharmacyacc")
               
        });
            action.setCallback(this, result => {
            component.set('v.ShowSpinner', false);
            if(result.getState() === 'SUCCESS') {
                let downloadLink = document.createElement('a');
                downloadLink.download = 'Enrollment Form.pdf';
                downloadLink.href = 'data:application/pdf;base64,'+result.getReturnValue();
                downloadLink.click();
            } else {
                helper.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
            }
            });
            $A.enqueueAction(action);
    },

    downloadOutPatientPharmayEnrollmentForm : function(component, event, helper) {
        component.set('v.ShowSpinner', true);
        var action = component.get("c.getOutPatientPharmacyEnrollmentForm");
        action.setParams({
            recordId :component.get("v.Pharmacyacc")
               
        });
           action.setCallback(this, result => {
           component.set('v.ShowSpinner', false);
           if(result.getState() === 'SUCCESS') {
           let downloadLink = document.createElement('a');
           downloadLink.download = 'Enrollment Form.pdf';
           downloadLink.href = 'data:application/pdf;base64,'+result.getReturnValue();
           downloadLink.click();
           } else {
               helper.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
           }
           });
           $A.enqueueAction(action);
   },

    downloadPrescriberEnrollmentForm : function(component, event, helper) {
            var action = component.get("c.getPrescriberEnrollmentForm");
            action.setCallback(this, result => {
            if(result.getState() === 'SUCCESS') {
            let downloadLink = document.createElement('a');
            downloadLink.download = 'Enrollment Form.pdf';
            downloadLink.href = 'data:application/pdf;base64,'+result.getReturnValue();
            downloadLink.click();
            } else {
                helper.showToast(component,event,'Something Went Wrong, Please contact SystemAdmin','Error'); 
            }
            });
            $A.enqueueAction(action);
    },

    navigateToChangePassword : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var nav = component.find("navigation");
        
        var pageReference = {
            type: "standard__webPage",
            attributes: {
               url: '/settings/'+userId
            }
        };
        nav.navigate( pageReference );
    },
    
    navigateToGeneralPage : function(component, event, helper) {
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'general'
        }
        };
        nav.navigate( pageReference );
    },
    
    navigateToContactUsPage : function(component, event, helper) {
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'contact-us'
        }
        };
        nav.navigate( pageReference );
    },

    navigateToFaqsPage : function(component, event, helper) {
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'faqs'
        }
        };
        nav.navigate( pageReference );
        var baseUrl = window.location.origin; // Get the base URL
        var FaqPage = $A.get("$Label.c.MacitentanFaqsPage");
        window.location.href = baseUrl + FaqPage;
    },
        
     navigateToPrelaunchPage : function(component, event, helper) {
         component.set('v.showPreLaunchModal', true);
     },
         
     closePreLaunchModal : function(component, event, helper) {
         component.set('v.showPreLaunchModal', false);
         component.set('v.showPreLaunchTab', false);
     },
            
})