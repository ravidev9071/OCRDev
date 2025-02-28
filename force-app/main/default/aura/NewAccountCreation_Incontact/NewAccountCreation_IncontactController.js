({
    doInit : function(component, event, helper){
        
         var myPageRef = component.get("v.pageReference");
        
        var callerId=myPageRef.state.c__callerId ? myPageRef.state.c__callerId : component.get("v.callerId");
        var contactId_incontact=myPageRef.state.c__contactId_incontact ? myPageRef.state.c__contactId_incontact : component.get("v.contactId_incontact");
        component.set("v.callerId",callerId);
        component.set("v.contactId_incontact",contactId_incontact);
        
        var action = component.get("c.getRecordTypeInfo");
        action.setCallback(this, function(res){
            var state = res.getState();
            var optionsLst=[];
            var rcTywraper = [];
            var rcObjWrap = {};
            debugger;
            if (state === "SUCCESS") {
                
                
                for (var index in res.getReturnValue() ){
                    if (index == '0'){
                        let value = res.getReturnValue()[index];
                        component.set("v.value", value['RCTypeName']);
                    }
                    let val = res.getReturnValue()[index];
                    optionsLst.push({ 'label' :val['RCTypeName'] , 'value' : val['RCTypeName']});
                    let WrapInfo ={
                        'pagelayoutName' : val['PagelayoutName'], 'recordTyId' :val['RCTypeId']
                    };
                    rcObjWrap[val['RCTypeName']] = WrapInfo;
                }
            }
            
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = res.getError();
                   
                }
            component.set("v.RCtypeWrap",rcObjWrap);
            component.set("v.options" , optionsLst);
        });
        
        $A.enqueueAction(action);
    },
    
    nextRec : function(component, event, helper) {
        
        
      	component.set("v.ShowRecType", false);
        let radioOption = component.get("v.value")
        var rctypeWrap = component.get("v.RCtypeWrap")[radioOption];
        component.set("v.CardTitleName", 'New '+radioOption);
        var childComponent = component.find('PGcom');
        childComponent.getPGlayout(rctypeWrap['pagelayoutName'],'Case',rctypeWrap['recordTyId'],'');
         
        
    },
    // Chai: sox Sprint9-BT6825 - 196
    previous : function(component, event, helper){
        helper.previousButton(component, event, helper);
    }
})