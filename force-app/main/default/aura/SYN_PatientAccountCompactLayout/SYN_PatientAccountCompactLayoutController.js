({
    doInit: function( component, event, helper ) {
        var action = component.get( "c.accountDataForCompactLayout" );
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback( this, function( response ) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accData", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
    },
  
   /* handlePreDispense: function( component, event, helper ) {
       // alert('1');
          event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "rdaflow" 
            },
            //Added state params to pass the id to flow (BT6825-457)
            state: {
                PatientID:component.get("v.recordId")
        }
        };  
        navService.navigate(pageReference); 
    },
   handlePCCL: function( component, event, helper ) {
        //var flow = component.find("launchPCCLFlow");     
       // flow.startFlow("SYN_PCCL_ScreenFlow");
        event.preventDefault();  
        var navService = component.find( "navService" );  
        var pageReference = {  
            type: "comm__namedPage",  
            attributes: {  
                pageName: "pcclflow" 
            },
            //Added state params to pass the id to flow (BT6825-456)
            state: {
                patientRecordId: component.get("v.recordId")
            }
        };  
        navService.navigate(pageReference);  
    },
    handleRMR: function( component, event, helper ) {
        // var flow = component.find("launchPCCLFlow");     
        // flow.startFlow("RMR");
        event.preventDefault();
                        var navService = component.find("navService");
                        debugger;
                        var pageReference = {
                            type: "comm__namedPage",
                            attributes: {
                                pageName: "RMR__c"
                            }
                        };
                        navService.navigate(pageReference);
                        debugger;
        
    },*/
    handleClick: function( component, event, helper ) {
        var clickedBtnName = event.getSource().getLocalId();
        helper.handlePermissions( component, event, helper, clickedBtnName);
    },
     closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
        }
    }
    
    
})