({
    
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    handleLogin: function (component, event, helper) {
        
        
        var username =  component.get("v.userName"); //component.find("username").get("v.value");
        var pwd =  component.get("v.passWord"); //component.find("password").get("v.value"); 
        
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        
        
        var programName = component.get("v.programName");
        
        startUrl = decodeURIComponent(startUrl);
        
        action.setParams({username:username, password:pwd, startUrl:startUrl, programName:programName});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
           
            if (rtnValue !== null || rtnValue=='') {
                
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
                component.set("v.showError",true);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },
    
    verifyUserName: function (component, event, helpler) {
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var programName = component.get("v.programName");
        var action = component.get("c.getUserName");
        action.setParams({username:username, programName:programName});
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            component.set("v.ShowSpinner",false);
            var userNameMap = [];
            var userName;
                for(var key in result){
                    userNameMap.push({key: key, value: result[key]});
                   	userName =  result[key];
                } 
            component.set("v.userRolesMap", userNameMap);
            if(userNameMap.length == 1){
                component.set("v.ShowSpinner",true);
            	this.validateUserCredentials(component, event, helpler,userName);
            }else if(userNameMap.length > 1){
            	component.set("v.showModal",true);
            }else{
                //alert('Sorry, We do not have user with provided username, Please contact Macitentan Support Team.');
                component.find('maciCustomNotification').showToast ("warning", "Sorry, We do not have user with provided username, please contact the Macitentan REMS at 1-888-572-2934.");  
            }
       });
        $A.enqueueAction(action);
    },
    
     validateUserCredentials : function (component,event, helpler,username) {
        
        component.set("v.userName",username);
        var password =  component.find("password").get("v.value");
        component.set("v.passWord",password);
       
        var startUrl = component.get("v.startUrl");
        var programName = component.get("v.programName");
        var programName = component.get("v.programName");
        var twoFAValue = component.get("v.value2FA");
        
        startUrl = decodeURIComponent(startUrl);
        
        var action = component.get("c.verifyUserCredentials");
        action.setParams({username:username, password:password, startUrl:startUrl, programName:programName,twoFAValue:twoFAValue });
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
             component.set("v.ShowSpinner",false);

            if(rtnValue == 'Opt-In'){
            	component.set("v.enableTwoFactoryAuthentication",true);
                component.set("v.show2FAOptions",false);
            }else if(rtnValue == 'Opt-Out'){
                component.set("v.enableTwoFactoryAuthentication",false);
                this.handleLogin(component, event, helpler);  
            }else if(rtnValue == 'valid'){
                component.set("v.show2FAOptions",true);
            }else if(rtnValue == 'notvalid'){
                //alert('Your account certification status is pending, please contact the Macitentan REMS at 1-888-572-2934.');
                 component.find('maciCustomNotification').showToast ("warning", "Your account certification status is pending, please contact the Macitentan REMS at 1-888-572-2934.");  
            }else {
                //alert('Your login attempt has failed. Make sure the username and password are correct.');
                component.find('maciCustomNotification').showToast ("warning", "Your login attempt has failed. Make sure the username and password are correct.");  
            }
        });
        $A.enqueueAction(action);
    },
    
})