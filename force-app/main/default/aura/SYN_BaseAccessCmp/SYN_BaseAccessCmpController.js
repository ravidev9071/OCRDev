({
	onInit: function( component, event, helper ) {
        // proactively search on component initialization
         var action = component.get( "c.retrievePortalButtonConfigurationData" );
        action.setParams({
           
            buttomName:'Search',
           
        });
        action.setCallback( this, function( response ) {
           // alert('In Base');
           component.set("v.haveAccess",response.getReturnValue().status);
           component.set("v.errorMessage",response.getReturnValue().buttonerrorMessage);
         
        });
        $A.enqueueAction( action );
    },
})