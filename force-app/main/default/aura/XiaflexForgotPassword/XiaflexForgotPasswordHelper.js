({
    handleForgotPassword: function (component, event, helpler) {
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var programName = component.get("v.programName");
        var ProgramType = component.get("v.ProgramType");
        var persona = component.get("v.value");
        var action = component.get("c.getUserNameXiaflex");
        action.setParams({username:username, programName:programName, ProgramType:ProgramType,persona:persona});
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            var userNameMap = [];
            var userName;
                for(var key in result){
                    userNameMap.push({key: key, value: result[key]});
                   	userName =  result[key];
                } 
            component.set("v.userRolesMap", userNameMap);
            if(userNameMap.length == 1){
                component.set("v.ShowSpinner",true);
            	this.sendForgotPasswordLink(component, event, helpler,userName);
            }else if(userNameMap.length > 1){
                component.find('maciCustomNotification').showToast ("warning", "Sorry, We do  have more than one user with provided email address with given Role, please contact the Xiaflex Support Team");
            }else{
                //alert('Sorry, We do not have user with provided email address, Please contact Macitentan Support Team.');
                component.find('maciCustomNotification').showToast ("warning", "Sorry, We do not have user with provided email address, please contact the Xiaflex Support Team");
            }
       });
        $A.enqueueAction(action);
    },
    
    sendForgotPasswordLink: function (component, event, helpler,username) {
        
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var action = component.get("c.forgotPassowrd");
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            component.set("v.ShowSpinner",false);
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }else{
                this.resetPassword(component, event, helpler,username);
            }
       });
        $A.enqueueAction(action);
    },
    
    resetPassword: function (component, event, helpler,username) {
        var programName = component.get("v.programName");
        var action = component.get("c.resetPasswordRequested");
        action.setParams({username:username, programName:programName});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
            }
       });
        $A.enqueueAction(action);
    }
})