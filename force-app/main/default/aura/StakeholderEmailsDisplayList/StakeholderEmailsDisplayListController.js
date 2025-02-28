({    
    doInit : function(component,event,helper){ 
        component.set('v.columns', [
            {label: 'Subject', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Related Record', fieldName: 'RelatedToId', type: 'url', 
            typeAttributes: {label: { fieldName: 'Subject' }, target: '_blank'}},
         ]);
            
        var action = component.get("c.getEmailMessageRecords");
        action.setParams({
            recordId : component.get("v.recordId")
        });
            
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                    record.RelatedToId = '/'+record.RelatedToId;
            //RelatedTo.Name is not getting set to the column so Here we are overriding the subject to 
            //show the related record name to the UI as Name is already being shown with the same subject content...
                    record.Subject = record.RelatedTo.Name;
                });
                component.set("v.EmailMessageList", records);
            }else{
                console.log('Error else--');
            }
        });
        $A.enqueueAction(action); 
    }
})