({
    init : function (cmp) {
        //Id ,CaseNumber, Status, US_WSREMS__REMS_Service_Summary__c
        console.log('RecordId'+cmp.get('v.recordId')+' >>  '+cmp.get("v.caseObj"));
        var caseRec = cmp.get("v.caseObj");
        debugger;
        if(caseRec){
            console.log('case');
            if(caseRec['Id']){
                var lastIndex = caseRec['Id'].lastIndexOf('/') + 1;
                var Id = caseRec['Id'].substring(lastIndex);
                cmp.set("v.caseId",Id);
                console.log('caseId'+cmp.get("v.caseId")+'' +Id);
                var flow = cmp.find("flowData");
                var inputVariables = [
                    {
                        name : 'recordId',
                        type : 'String',
                        value : cmp.get('v.caseId')
                    }
                    
                ];
                flow.startFlow("Disenrollment_Case_Update",inputVariables);
            }
        }  else{
            
            var flow = cmp.find("flowData");
            var inputVariables = [
                {
                    name : 'recordId',
                    type : 'String',
                    value : cmp.get('v.recordId')
                }
                
            ];
            flow.startFlow("Disenrollment_Case_Flow",inputVariables);
        }
    },
    handleStatusChange : function (component, event) {
        
        
        if(event.getParam("status") === "STARTED") {
            if(!component.get("v.isCaseData")){
            var columnList = ["Id","CaseNumber","Status"];
            var docDetId =component.get("v.docDetailIdVal");
            debugger;
            var dynamicAttribute = {
                "DocDetailId": docDetId,
                "Source":"CaseColumns",
                "CaseColumns":columnList
            };
                component.set("v.isCaseData",true);
            component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);
            }
        }
        if(event.getParam("status") === "FINISHED") {
            
            /*  var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
               "recordId": component.get('v.recordId'),
               "isredirect": "true"
            });
            urlEvent.fire();*/
       var dynamicAttribute = {
           "DocDetailId": component.get("v.docDetailIdVal"),
           "REMSServiceId": component.get("v.recordId"),
           "Source":"NewCase"
       };
       component.find("REMSReviewDocumentChannel").publish(dynamicAttribute);
   }
  }
    
    
})