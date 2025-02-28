({
    doInit : function(cmp, event, helper) {
        
        
        
        var action = cmp.get("c.getQuestionAndResponse");
        action.setParams({
            "recId":cmp.get("v.recordId"),
            "responses":''
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                cmp.set("v.surveysList",response.getReturnValue());
  
    cmp.set("v.showTable",true);
}
});
    $A.enqueueAction(action);
},
    fetchQA : function(cmp,event,helper) {
        var itemId = event.target.id;
        var responses = cmp.get("v.surveysList");
        var qas =responses.filter((item) => item.SurveyName+'-'+item.Id === itemId); //responses[itemId];
        var dataTable = '<div ><table class="slds-table slds-table_bordered" style="width:100%;"><tr><th class="boldClass">Question</th><th class="boldClass">Response</th></tr>';
        if(qas != undefined && qas[0].qstnsrespList !=null && qas[0].qstnsrespList.length>0) {
            for(var i=0;i<qas[0].qstnsrespList.length;i++){
                dataTable+='<td>'+qas[0].qstnsrespList[i].Question+'</td>';
                dataTable+='<td class="tablesty">'+qas[0].qstnsrespList[i].Response+'</td>';
                dataTable+='</tr>';
            }
            dataTable+='</table></div>';
            document.getElementById(itemId+'_removeButton').style.display = 'inline-block';
            document.getElementById(itemId+"body").innerHTML =dataTable;
            document.getElementById(itemId+"tr").style.display = 'table-row';
        } else {
            document.getElementById(itemId+'_removeButton').style.display = 'inline-block';
            document.getElementById(itemId+"body").innerHTML ='<p style="text-align:center;font-weight:bold">No Data Found</p>';
            document.getElementById(itemId+"tr").style.display = 'table-row';
        }
        
        
    },
    hideQAS : function(component, event, helper){
        
        var buttomItemId = event.target.id;
        var itemId= buttomItemId.replace('_removeButton','');
        document.getElementById(itemId+"body").innerHTML ='';
        document.getElementById(itemId+"tr").style.display = 'none';
        document.getElementById(buttomItemId).style.display = 'none';
        document.getElementById(itemId).style.display = 'inline-block';
    }
})