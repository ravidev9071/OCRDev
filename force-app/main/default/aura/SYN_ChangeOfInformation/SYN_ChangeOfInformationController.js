({
	init : function(component, event, helper) {
         var caseRec = component.get("v.caseObj");
          if(caseRec){
             console.log('case');
                if(caseRec['Id']){
                var lastIndex = caseRec['Id'].lastIndexOf('/') + 1;
                var Id = caseRec['Id'].substring(lastIndex);
                component.set("v.caseId",Id);
                 console.log('caseId'+component.get("v.caseId")+'' +Id);
                }
            }
		
	}
})