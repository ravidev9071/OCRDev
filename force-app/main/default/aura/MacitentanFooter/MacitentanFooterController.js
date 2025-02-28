({
	scriptsLoaded : function(component, event, helper) {
		 var hostname = window.location.hostname;
         var PageName=window.document.title;
         var baseUrl= component.get('v.baseUrl'); 
        
         var ConURL='https://'+hostname+baseUrl;
         component.set('v.contactusURL', ConURL); 
       
        if(PageName=='Login')
        {
            component.set('v.isLoginURL', true);   
        }
		
	},
    
    navigateToContactUsPage : function(component, event, helper) {
        var nav = component.find("navigation");
        var pageReference = {
        type: "comm__namedPage",
        attributes: {
            pageName: 'contact-us'
        }
        };
        nav.navigate( pageReference );
    },
})