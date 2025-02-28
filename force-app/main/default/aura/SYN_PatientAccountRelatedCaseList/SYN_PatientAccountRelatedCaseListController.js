({
    doInit: function( component, event, helper ) {
        var cols = [
            {
                'label': 'Type',
                'fieldName': 'Case_Record_Type_Name__c',
                'type': 'text',
                'sortable':'true',
                 cellAttributes: {
                    class: {
                        fieldName: 'TypeCellClass'
                    }
                }
               
            },
            {
                'label': 'Status',
                'fieldName': 'Status',
                'type': 'text',
                'sortable':'true',
                 cellAttributes: {
                    class: {
                        fieldName: 'StatusCellClass'
                    }
                }
            },
            {
                label: 'Created Date',
                fieldName: 'CreatedDate',
                type: 'date',
                sortable:'true',
                typeAttributes:
                {day:'numeric',month:'numeric',year:'numeric'},
                 cellAttributes: {
                    class: {
                        fieldName: 'CreatedDateCellClass'
                    }
                }
            },
            {
                label: 'RDA Outcome',
                fieldName: 'US_WSREMS__Outcome__c',
                type: 'text',
                sortable:'true',
                 cellAttributes: {
                    class: {
                        fieldName: 'RDAOutcomeCellClass'
                    }
                }
            },
            
            {
                'label': 'Action',
                'type': 'button',
                'typeAttributes': {
                    'label': 'View Record',
                    'name': 'view_details',
                    'variant': 'brand',
                }
            }
        ];
        component.set( 'v.cols', cols );
       /* var recId = component.get("v.recordId");
        if(recId.startsWith('001')){
            component.set("v.showPatientSearchComp",true);
        }else{
            component.set("v.showPatientSearchComp",false);
        }
        */
        helper.getRecords(component, event, helper);
    },
    onRowAction: function( component, event, helper ) {
        var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        if ( action.name == 'view_details' ) {
            var navEvent = $A.get("e.force:navigateToSObject");  
            navEvent.setParams({
                "recordId": row.Id,   
                "slideDevName": "detail"
            });
            
            navEvent.fire(); 
        }
    },
    handleSort: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        
       component.set("v.sortedBy",fieldName);
       component.set("v.sortedDirection",sortDirection);
        
        var action = component.get( "c.displayCaseRecs" );
        action.setParams({
            recordId: component.get("v.recordId"),
            sortedBy:component.get("v.sortedBy"),
            sortedDirection:component.get("v.sortedDirection"),
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

        component.set( 'v.rows', allrows );
                
                //component.set("v.rows", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
        var paginationCmp = component.find("cPagination");
        paginationCmp.RefreshPagination();
    },
    handlePagination: function(cmp, event, helper) {
        var currentPageValue = event.getParam("currentPageValue");
        helper.buildData(cmp, currentPageValue);
    },
});