({
	sendEmails : function(component, event, helper) {
		var sendinvitation = component.find("sendInvite").set("v.value", true);
         component.find('curEditform').submit(sendinvitation);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        this.showToast(component,event,'Invitation sent successfully.','success'); 
	},
    
    showToast : function(component, event, errMsg,titleType) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : titleType,
                message: errMsg,
                duration:'10000',
                key: 'info_alt',
                type: titleType,
                mode: 'pester'
            });
            toastEvent.fire();
	},
    
})