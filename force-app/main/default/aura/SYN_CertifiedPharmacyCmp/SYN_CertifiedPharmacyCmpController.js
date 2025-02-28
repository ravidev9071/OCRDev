({
	doInit : function(component, event, helper) {
		var accountList = component.get("c.getCertifiedAccounts");
       
         accountList.setParams({
          
            PharmacyName:'',
            DEA:'',
            NPI:''
          
        });
        accountList.setCallback(this, function(data) 
                           {
                               component.set("v.accountList", data.getReturnValue());
                           });
        $A.enqueueAction(accountList);
        
        
 },
     onSearchTermChange: function( component, event, helper ) {
        
        var PharmacyName = component.get( "v.PharmacyNameSearch" );
        var DEA = component.get( "v.DEASearch" );
        var NPI = component.get("v.NPISearch");
       
          if((PharmacyName == '' || PharmacyName == null) && (DEA == ''||DEA ==null ) && (NPI == ''||NPI ==null)){
         
          } else{
               helper.handleSearch(component);
          }
    },


})