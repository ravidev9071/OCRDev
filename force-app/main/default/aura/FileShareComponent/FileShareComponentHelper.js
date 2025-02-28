({
	
    getBaseUrl:function(){
        let baseUrl = 'https://'+location.host+'/';
        return baseUrl;
    },
    navigate : function(component, event,helper,url_file) {
       
         component.find("navigate").navigate({
            type: "standard__webPage",
            attributes: {
               url:url_file
               
            }
        });
       
                   
    },
     getobjType:function(component, event,helper,url_file){
        var ConList = component.get("c.getObjType");
        ConList.setParams
        ({
            recordId: component.get("v.recordId")
        });
        
        ConList.setCallback(this, function(data) 
                           {
                               
                               
                               component.set("v.isShow", data.getReturnValue());
                           });
        $A.enqueueAction(ConList);
    },
 
})