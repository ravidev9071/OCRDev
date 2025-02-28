({
	doInit : function(component, event, helper) {
		var ConList = component.get("c.getContentDetailsWrapper");
        ConList.setParams
        ({
            recordId: component.get("v.recordId")
        });
        
        ConList.setCallback(this, function(data) 
                           {
                               component.set("v.ContentList", data.getReturnValue());
                           });
        $A.enqueueAction(ConList);
       helper.getobjType(component,event,helper); 
        
 },
  
    handleDownload :function(component,event, helper){
      
        var baseUrl=helper.getBaseUrl();
        var fieldId=event.getSource().get("v.value");
        var url_file=baseUrl+'sfc/servlet.shepherd/document/download/'+fieldId;
        helper.navigate(component,event,helper,url_file);
       
         window.setTimeout(
   			 $A.getCallback(function() {
        var url_pop='http://127.0.0.1:8887';
         var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": url_pop
    });
    urlEvent.fire();
    }), 4000
);
        
       
     
    },
     handleDownloadselect :function(component,event, helper){
      
        var baseUrl=helper.getBaseUrl();
        var fieldId=event.getSource().get("v.value");
        var url_file=baseUrl+'sfc/servlet.shepherd/document/download/'+fieldId;
        helper.navigate(component,event,helper,url_file);
        
        var divv=document.getElementById("exampleInput");
        divv.click();
        
      
    },
     handlepreviewSelect :function(component,event, helper){
      
       
        var fieldId1=event.currentTarget.dataset.id;
        
         component.find("navigatePre").navigate({
            type: "standard__namedPage",
            attributes: {
               pageName: 'filePreview'
               
            },
             state : {
                    selectedRecordId: fieldId1
             }
             });

       
        
        
      
    },
   
	
})