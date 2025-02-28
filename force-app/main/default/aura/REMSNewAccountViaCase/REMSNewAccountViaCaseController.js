({
    doInit : function(component, event, helper){
        var programName = component.get("v.programName");
        console.log('----programName New----'+programName);
        var action = component.get("c.getRecordTypeInfo");
         action.setParams({
            "ProgramName" : programName,
             "ObjectName" : 'Case'
        });
        action.setCallback(this, function(res){
            var state = res.getState();
            var optionsLst=[];
            var rcTywraper = [];
            var rcObjWrap = {};
            //debugger;
            if (state === "SUCCESS") {
                console.log('Success value '+JSON.stringify(res.getReturnValue()));
                
                for (var index in res.getReturnValue() ){
                    if (index == '0'){
                        let value = res.getReturnValue()[index];
                        component.set("v.value", value['RCTypeName']);
                    }
                    let val = res.getReturnValue()[index];
                    optionsLst.push({ 'label' :val['RCTypeName'] , 'value' : val['RCTypeName']});
                    let WrapInfo ={
                        'pagelayoutName' : val['PagelayoutName'], 'recordTyId' :val['RCTypeId'], 'programRecord' :val['programRecordType']
                    };
                    rcObjWrap[val['RCTypeName']] = WrapInfo;
                }
            }
            
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = res.getError();
                    console.log("error "+JSON.stringify(errors));
                }
            component.set("v.RCtypeWrap",rcObjWrap);
            component.set("v.options" , optionsLst);
        });
        
        $A.enqueueAction(action);
        
    },
    
    nextRec : function(component, event, helper) {
        
        /* component.set("v.Pagelayout",rctypeWrap['pagelayoutName']);
        component.set("v.objectName",'Case');
        component.set("v.RecordTypeId",rctypeWrap['recordTyId']);
       */
      	component.set("v.ShowRecTypesOption", false);
        var programName = component.get("v.programName");
		let radioOption = component.get("v.value")
        var rctypeWrap = component.get("v.RCtypeWrap")[radioOption];
        component.set("v.CardTitleName", 'New '+radioOption);
        var childComponent = component.find('PGcom');
        childComponent.getPGlayout(rctypeWrap['pagelayoutName'],'Case',rctypeWrap['recordTyId'],'',programName,component.get("v.calledByFaxTransfo"),rctypeWrap['programRecord']);

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