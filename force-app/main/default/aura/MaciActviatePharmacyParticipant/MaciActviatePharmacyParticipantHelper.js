({
  
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