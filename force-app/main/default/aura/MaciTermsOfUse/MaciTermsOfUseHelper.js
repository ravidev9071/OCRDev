({
	getCurrentUserType : function (component, event, helpler) {
		var action = component.get("c.getCurrentUserType");
        var termsType = component.get("v.footerTermsType");
        var temsOfUse = $A.get('$Resource.termsofuse');
         var privacypolicy = $A.get('$Resource.privacypolicy');
         action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
                component.set('v.currentUser', resultData);
            }
             this.termsAndConditions(component, event, helpler);
        });
        
        $A.enqueueAction(action);
	},
    
    termsAndConditions : function(component, event, helper) {
        var termsType = component.get("v.footerTermsType");
        if(termsType == 'termsofuse'){
            var temsOfUse = $A.get('$Resource.termsofuse');
            window.open(temsOfUse,'_Self');
        }else if(termsType == 'privacypolicy'){
            var privacypolicy = $A.get('$Resource.privacypolicy');
            window.open(privacypolicy,'_Self');
        }
	},
})