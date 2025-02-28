({
    onAccountsLoaded: function( component, event, helper ) {
        var cols = [
            
            {
                label: 'First Name',
                fieldName: 'FirstName',
                type: 'text',
                //initialWidth:80,
                sortable:'true'
            },
            {
                label: 'Last Name',
                fieldName: 'LastName',
                type: 'text',
                // initialWidth:80,
                sortable:'true'
            },
            {
                label: 'Status',
                fieldName: 'US_WSREMS__Status__c',
                type: 'picklist',
                // initialWidth:80,
                sortable:true,
                cellAttributes: {
                    class: {
                        fieldName: 'statusCellClass'
                    }
                }
            },
            /* {
                'label': 'DOB',
                'fieldName': 'US_WSREMS__DOB__c',
                'type': 'text',
                'sortable':'true',
                'day': 'numeric',
                'month': 'short', 
                'year': 'numeric'
            }, */
            {label: 'DOB',
             fieldName: 'US_WSREMS__DOB__c',
             type: 'date-local',
             sortable:true,
             // initialWidth:100,
             typeAttributes:
             {day:'numeric',month:'numeric',year:'numeric'}},
            
            {
                label: 'Phone',
                fieldName: 'Phone',
                type: 'phone',
                // initialWidth:100,
                sortable:true
            },
            {
                label: 'Zip Code',
                fieldName: 'ShippingPostalCode',
                type: 'text',
                // initialWidth:100,
                sortable:true
            },
            {
                label: 'Latest PCCL',
                sortable:false,
                fieldName: '',
                //  initialWidth:150,
                type: ''
                
            },
            {
                label: 'Latest RDA',
                sortable:false,
                initialWidth:150,
                fieldName: '',
                type: ''
                
            },
            {
                label: 'Action',
                type: 'button',
                initialWidth:150,
                typeAttributes: {
                    label: 'View Record',
                    name: 'view_Records',
                    variant: 'brand',
                },
                cellAttributes: {
                    class: 'font-css',
                },
            }
            
        ];
        component.set( 'v.cols', cols );
        var allrows = event.getParam( 'accounts' );
                for ( var i = 0; i < allrows.length; i++ ) {
                    var row = allrows[i];
                    if ( row.US_WSREMS__Status__c=="Disenrolled" ) {
                        row.statusCellClass = "slds-truncate slds-text-color_error";
                    }  
                }

        component.set( 'v.rows', allrows );
        /*  var res = event.getParam( 'accounts' );
        if(res.length > 0) {
                    res.forEach(function(record){
                        
                        if(record.Id != '' && record.Id != null){
                            record.Id = '/'+record.Id;
                        }
                       
                        
                    });
                  component.set( 'v.rows', res );*/
        helper.buildData(component, 1);
        var result=event.getParam('accounts').length;
        //alert(result);
        if(result>0){
            component.set("v.haveSearchTerm",true);
            var paginationCmp = component.find("cPagination");
            paginationCmp.RefreshPagination();
        }else{
            component.set("v.haveSearchTerm",false);
        }
        
        
    },
    onRowAction: function( component, event, helper ) {
       // alert('Hi');
        var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
        
        //alert(row.Id);
        if ( action.name == 'view_Records' ) {
           
                /* var navigation = component.find( 'navigation' );
            navigation.navigate({
                'type': 'standard__recordPage',
                'attributes': {
                    'objectApiName': 'Account',
                    'recordId': row.Id,
                    'actionName': 'view'
                }
            });*/
                
                var navEvent = $A.get("e.force:navigateToSObject");  
                navEvent.setParams({
                    "recordId": row.Id,   
                    "slideDevName": "detail"
                });
                
                navEvent.fire(); 
            } 
            
            /* var payload = {
                recordId: row.Id,
                name: "Test"
            };
            
            component.find("sampleMessageChannel").publish(payload);*/
            
            /* var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "https://syneoshealth4--soxdev.lightning.force.com/lightning/r/Account/"+ row.Id
            });
            urlEvent.fire();*/
        
    },
    
    handleSort: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        // alert(cmp.get("v.sortedBy"));
        var event = $A.get( "e.c:SYN_PharmacySortEve" );
        event.setParams({
            "SortingField":cmp.get("v.sortedBy"),
            "SortingDirection" :cmp.get("v.sortedDirection")
        });
        event.fire();
        var paginationCmp = cmp.find("cPagination");
        paginationCmp.RefreshPagination();
        // helper.getsortData(cmp, fieldName, sortDirection);
    },
    
    handlePagination: function(cmp, event, helper) {
        var currentPageValue = event.getParam("currentPageValue");
        helper.buildData(cmp, currentPageValue);
    },
})