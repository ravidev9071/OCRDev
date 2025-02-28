({
	handlePermissions : function(component, event, helper,clickedBtnName) {
        //alert('11');
       // alert(clickedBtnName);
        
		var action = component.get( "c.getPermissionsBasedonAccountStatus" );
        action.setParams({
            buttonName: clickedBtnName
        });
        action.setCallback( this, function( response ) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accountPermissionsWrapper", response.getReturnValue());
                var accdata = component.get("v.accountPermissionsWrapper");
                var status = accdata.status;
                var erroeMsg = accdata.buttonerrorMessage;
                //alert(JSON.stringify(accdata));
                if(clickedBtnName == 'editinfo'){
                    if(status == true){
                          component.set('v.isOpen', true);
                       var flow = component.find("EditPatientInfo"); 
                        var inputVariable = [{
                             name : "RecordId",
                			type : "String",
                			value : component.get("v.recordId")
                        }]
                        flow.startFlow("Edit_Account_information",inputVariable);
                        event.preventDefault();
                    }else if(status == false){
                       this.openAlert(component,erroeMsg); 
                    }
                }else if(clickedBtnName == 'RDAbutton'){
                    if(status == true){
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
                    }else if(status == false){
                        this.openAlert(component,erroeMsg);  
                    }
                }else if(clickedBtnName == 'pcclButton'){
                    if(status == true){
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
                    }else if(status == false){
                        this.openAlert(component,erroeMsg);
                    }
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
        
        
	},
    openAlert: function(component,erroeMsg) {
        
        this.LightningAlert.open({
            message: erroeMsg,
            theme: 'default',
            label: '',
        }).then(function() {
            console.log('alert is closed');
        });
    }
})