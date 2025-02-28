({
    // code in the helper is reusable by both
    // the controller.js and helper.js files
    handleSearch: function( component, searchTerm ) {
        //alert('In Search'+component.get("v.haveAccess"));
         if(component.get("v.haveAccess")){
        var radioValue = component.get("v.value");
        var firstName = component.get( "v.FirstNameSearch" );
        var LastName = component.get( "v.LastNameSearch" );
        var DOB = component.get( "v.DOBSearch" );
        var Phone = component.get( "v.PhoneSearch" );
        var ZipCode = component.get( "v.ZipSearch" );
        var SortedBy=component.get( "v.sortedBy" );
        var SortedDirection=component.get( "v.sortedDirection" );
        var radioBtnRecsOnly = component.get("v.LoadRadioBtnRecs");
        var radioBtnRecsOnlyMyPAt = component.get("v.LoadMYPatRadioBtnRecs");
        
        if(radioValue == "mypatients" && ((firstName == undefined || firstName == '') && (LastName == undefined || LastName == '') && (DOB == undefined || DOB == '') && (Phone == undefined || Phone == '') && (ZipCode == undefined || ZipCode == '')) || radioBtnRecsOnlyMyPAt == true){
            component.set("v.myPatientsBool",true);
            component.set("v.searchTermBool",false);
            //alert(1);
        }else if(radioValue == "allpatients" && ((firstName == undefined || firstName == '') && (LastName == undefined || LastName == '') && (DOB == undefined || DOB == '') && (Phone == undefined || Phone == '') && (ZipCode == undefined || ZipCode == '')) || radioBtnRecsOnly == true){
            component.set("v.myPatientsBool",false); 
            component.set("v.searchTermBool",false);
            //alert(2);
        }else if(radioValue == "mypatients" && radioBtnRecsOnlyMyPAt == false && (firstName != undefined || LastName != undefined ||  DOB != undefined || Phone != undefined  || ZipCode != undefined)){
            component.set("v.myPatientsBool",true); 
            component.set("v.searchTermBool",true);
            //alert(3);
        }else if(radioValue == "allpatients" && radioBtnRecsOnly == false && (firstName != undefined || LastName != undefined ||  DOB != undefined || Phone != undefined  || ZipCode != undefined)){
            component.set("v.myPatientsBool",false); 
            component.set("v.searchTermBool",true);
            //alert(4);
        }
        
        var myPatientBool = component.get("v.myPatientsBool");
        var searchTermBool = component.get("v.searchTermBool"); 
        
        var action = component.get( "c.searchAccounts" );
        action.setParams({
            myPatientBool: myPatientBool,
            searchTermBool:searchTermBool,
            firstName:firstName,
            LastName:LastName,
            DOB:DOB,
            Phone:Phone,
            ZipCode:ZipCode,
            SortingField:SortedBy,
            SortingDirection:SortedDirection
        });
        action.setCallback( this, function( response ) {
            component.set("v.allData",response.getReturnValue());
            var event = $A.get( "e.c:SYN_PatientAccountsLoaded" );
            event.setParams({
                "accounts": response.getReturnValue()
            });
            event.fire();
        });
        $A.enqueueAction( action );
           }else{
               this.openAlert(component);
          }
    },
    sortData: function (cmp, fieldName, sortDirection) {
        debugger;
        var fname = fieldName;
        var data = cmp.get("v.allData");
        
        let parseData = JSON.parse(JSON.stringify(cmp.get("v.allData")));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldName];
        };
        // cheking reverse direction
        let isReverse = sortDirection === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        // component.set("v.allData",parseData);
        cmp.set("v.allData", parseData);
        var event = $A.get( "e.c:SYN_PatientAccountsLoaded" );
        event.setParams({
            "accounts": parseData
        });
        event.fire();
        
        
        
        
        
        
        
        
        /* var reverse = sortDirection !== 'asc';
            data.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData; */
            
            //data.sort(this.sortBy(cmp,fieldName, reverse))
            
        },
    sortBy: function (component,field, reverse) {
        debugger;
        /*  var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.allData");

        sortAsc = sortField != field || !sortAsc
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);

        });*/
        
        var key = function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            a = key(a);
            b = key(b);
            
            return  reverse * ((a > b) - (b > a));
            
        }
    },
    showToast: function (component, variant, title, message, messageData, mode) {
         component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "messageData": messageData,
            "mode": mode,
            "variant": variant
        });
        //toastEvent.fire();
        
    },
     openAlert: function(component) {
        
        this.LightningAlert.open({
            message: component.get("v.errorMessage"),
            theme: 'default',
            label: '',
        }).then(function() {
            console.log('alert is closed');
        });
    }
})