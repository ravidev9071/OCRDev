({
    doInit : function(component, event, helper){
      
        var action = component.get("c.getRecordTypeInfo");
        action.setCallback(this, function(res){
            var state = res.getState();
            var optionsLst=[];
            var rcTywraper = [];
            var rcObjWrap = {};
            
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
        
        
        var programName = component.get("v.programName");
      	component.set("v.ShowRecType", false);
        let radioOption = component.get("v.value")
        var rctypeWrap = component.get("v.RCtypeWrap")[radioOption];
        component.set("v.CardTitleName", 'New '+radioOption);
        var childComponent = component.find('PGcom');
        childComponent.getPGlayout(rctypeWrap['pagelayoutName'],'Case',rctypeWrap['recordTyId'],programName,'',component.get("v.parentRecordId"),component.get("v.calledByFaxTransfo"));
         
        
    },

    previous : function(component, event, helper){
        if (component.get("v.calledByFaxTransfo") == false){
            helper.previousButton(component, event, helper);
        }else {
            helper.previousButtonFaxTransformation(component);
        }
    },
    
    handleShowScreen: function(component,event,helper){
        helper.showScreen(component,event);
    },

})