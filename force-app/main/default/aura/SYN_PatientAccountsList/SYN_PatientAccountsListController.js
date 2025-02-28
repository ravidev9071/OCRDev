({
    onAccountsLoaded: function( component, event, helper ) {
        var cols = [
            
            {
                'label': 'First Name',
                'fieldName': 'FirstName',
                'type': 'text',
                'sortable':'true'
            },
             {
                'label': 'Last Name',
                'fieldName': 'LastName',
                'type': 'text',
                'sortable':'true'
            },
            {
                label: 'Status',
                fieldName: 'US_WSREMS__Status__c',
                type: 'text',
                sortable:'true',
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
             sortable:'true',
             typeAttributes:
                   {day:'numeric',month:'numeric',year:'numeric'}},
            {
                'label': 'Zip Code',
                'fieldName': 'ShippingPostalCode',
                'type': 'text',
                initialWidth:100,
                sortable:true
            },
            {
                'label': 'Phone',
                'fieldName': 'Phone',
                'type': 'phone',
                'sortable':'true'
            },
            {
                'label': 'Action',
                'type': 'button',
                'typeAttributes': {
                    'label': 'View Record',
                    'name': 'view_details',
                    'variant': 'brand',
                },
                cellAttributes: {
                    class: 'font-css',
                },
            }
        ];
        component.set( 'v.cols', cols );
        var allrecs = event.getParam('accounts');
                for ( var i = 0; i < allrecs.length; i++ ) {
                    var row = allrecs[i];
                    if ( row.US_WSREMS__Status__c == "Disenrolled" ) {
                        row.statusCellClass = "slds-truncate slds-text-color_error";
                    }  
                }
        
        component.set('v.rows',allrecs);
     
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
        
        
        /*
        let countTotalPage = Math.ceil(event.getParam('accounts').length/component.get("v.pageSize"));
        let totalPage = countTotalPage > 0 ? countTotalPage : 1;
        component.set("v.totalPages", totalPage);
                var allrecs  = event.getParam( 'accounts' );
                var pageSize = component.get("v.pageSize");
                // hold all the records into an attribute named "ContactData"
              //  component.set('v.ContactData', response.getReturnValue());
                // get size of all the records and then hold into an attribute "totalRecords"
                component.set("v.totalRecords", allrecs.length);
                // set star as 0
                component.set("v.startPage",0);
                component.set("v.endPage",pageSize);
                var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.rows").length> i)
                        PaginationList.push(allrecs[i]);    
                }
                component.set('v.PaginationList', PaginationList);*/
        
        
         component.set('v.listOfAllAccounts', allrecs);
                 /*   var pageSize = component.get("v.pageSize");
                    var totalRecordsList = allrecs;
       // alert(totalRecordsList);
        var totalLength = totalRecordsList!=undefined && totalRecordsList!= null? totalRecordsList.length:0 ;
                    component.set("v.totalRecordsCount", totalLength);
                    component.set("v.startPage",0);
                    component.set("v.endPage",pageSize-1);
                    
                    var PaginationLst = [];
                    for(var i=0; i < pageSize; i++){
                        if(component.get("v.listOfAllAccounts")!= null && component.get("v.listOfAllAccounts").length > i){
                            PaginationLst.push(allrecs[i]);    
                        } 
                    }
                    component.set('v.PaginationList', PaginationLst);
                    component.set("v.selectedCount" , 0);
                    //use Math.ceil() to Round a number upward to its nearest integer
                    component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize))
               */
        
       // helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));

    },
    onRowAction: function( component, event, helper ) {
        var action = event.getParam( 'action' );
        var row = event.getParam( 'row' );
      
        if ( action.name == 'view_details' ) {
            var navigation = component.find( 'navigation' );
            navigation.navigate({
                'type': 'standard__recordPage',
                'attributes': {
                    'objectApiName': 'Account',
                    'recordId': row.Id,
                    'actionName': 'view'
                }
            });
            
           /* var payload = {
                recordId: row.Id,
                name: "Test"
            };
            
            component.find("sampleMessageChannel").publish(payload); */
        }
        
        
    },
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllAccounts");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
     
    },
    handleSort: function (cmp, event, helper) {
        debugger;
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

   /*  next: function (component, event, helper) {
        helper.next(component, event);
    },
    previous: function (component, event, helper) {
        helper.previous(component, event);
    }*/
})