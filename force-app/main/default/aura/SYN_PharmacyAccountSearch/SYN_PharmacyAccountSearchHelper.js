({
    handleSearch: function( component ) {
        if(component.get("v.haveAccess")){
        var firstName = component.get( "v.FirstNameSearch" );
        var LastName = component.get( "v.LastNameSearch" );
        var DOB = component.get( "v.DOBSearch" );
        var Phone = component.get( "v.PhoneSearch" );
        var ZipCode = component.get( "v.ZipSearch" );
        var SortedBy=component.get( "v.sortedBy" );
        var SortedDirection=component.get( "v.sortedDirection" );
    
                                          
        var action = component.get( "c.searchAccounts" );
        action.setParams({
            firstName:firstName,
            LastName:LastName,
            DOB:DOB,
            Phone:Phone,
            ZipCode:ZipCode,
            SortingField:SortedBy,
            SortingDirection:SortedDirection
        });
        action.setCallback( this, function( response ) {
            var event = $A.get( "e.c:SYN_PharmacyAccountsLoaded" );
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
    
     showToast: function (component, variant, title, message, messageData, mode) {
        component.find('notifLib').showToast({
            "title": title,
            "message": message,
            "messageData": messageData,
            "mode": mode,
            "variant": variant
        });
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