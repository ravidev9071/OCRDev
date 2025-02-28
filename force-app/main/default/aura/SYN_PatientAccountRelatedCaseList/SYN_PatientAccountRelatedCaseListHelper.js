({
	getRecords : function(component, event, helper) {
        var recId = component.get("v.recordId");
        if(recId.startsWith('001')){
            component.set("v.showPatientSearchComp",true);
        }else{
            component.set("v.showPatientSearchComp",false);
        }
        var boolVal = component.get("v.showPatientSearchComp");
        
		var action = component.get( "c.displayCaseRecs" );
        component.set("v.sortedBy", null);
        component.set("v.sortedDirection", null);
        action.setParams({
            recordId: component.get("v.recordId"),
            sortedBy:component.get("v.sortedBy"),
            sortedDirection:component.set("v.sortedDirection"),
            PatientorPharmacy:component.get("v.remsRecordType")
            
        });
        action.setCallback( this, function( response ) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var allrows = response.getReturnValue();
                for ( var i = 0; i < allrows.length; i++ ) {
                    var row = allrows[i];
                     if ( row.SYN_Should_patient_be_monitored__c=="Yes" ) {
                        row.TypeCellClass = "slds-truncate textcolor";
                         row.StatusCellClass = "slds-truncate textcolor";
                         row.CreatedDateCellClass = "slds-truncate textcolor"
                         row.RDAOutcomeCellClass = "slds-truncate textcolor"
                         
                    }  
                }
        component.set( 'v.allrows', allrows );
        this.buildData(component, 1);
        var rowres = component.get("v.allrows");
        var result = rowres.length;
        
        if(result>0){
            var paginationCmp = component.find("cPagination");
            paginationCmp.RefreshPagination();
        }
                
                //component.set("v.rows", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

	},
    buildData:  function(cmp, pageNo) {
        var callList = cmp.get("v.allrows");
        var noOfCalls = cmp.get("v.noOfCallsToBeShown");
        var callListToBeShown = [];
        for(var i=(pageNo-1)*noOfCalls; i<(pageNo*noOfCalls); i++) {
            if(callList[i]) {
                callListToBeShown.push(callList[i]);
            }
        }
        cmp.set('v.rows', callListToBeShown);
         
    },
})