({
	 handleSearch: function( component ) {
         var PharmacyName = component.get( "v.PharmacyNameSearch" );
        var DEA = component.get( "v.DEASearch" );
        var NPI = component.get("v.NPISearch");
    
                                          
        var action = component.get( "c.getCertifiedAccounts" );
        action.setParams({
          
            PharmacyName:PharmacyName,
            DEA:DEA,
            NPI:NPI
          
        });
        action.setCallback( this, function( data ) {
            component.set("v.accountList", data.getReturnValue());
        });
        $A.enqueueAction( action );
    }, 
})