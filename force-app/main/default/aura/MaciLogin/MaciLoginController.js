({
    
     initialize : function( component, event, helper ) {  
       
         $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
         component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component, event, helper));
         component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component, event, helper));
         component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component, event, helper));
         component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component, event, helper));
         var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
         if(isMaciProgramLive == 'No'){   
             component.set('v.showPreLaunchModal', true);
         }else{
             component.set('v.showPreLaunchModal', false);
         }
    },
      
    handleLogin1: function (component, event, helper) {
        component.find('maciCustomNotification').closePreviousModal();
        var username = component.find("username").get("v.value");
        var password =  component.find("password").get("v.value");
        var errorMsg='';
        var isMaciProgramLive= $A.get("$Label.c.Is_Maci_Program_Live");
        var show2FAOptions = component.get("v.show2FAOptions");
        var twoFAValue = component.get("v.value2FA");
        if(isMaciProgramLive != 'No'){ 
            if(username == undefined || username == ''){
               errorMsg += ' username,' 
            }
            if(password == undefined || password == ''){
               errorMsg += ' password,' 
            }
            if(errorMsg){
                errorMsg = errorMsg.replace(/,*$/, '.');
                errorMsg = 'Please enter '+errorMsg;               
                component.find('maciCustomNotification').showToast ("warning", errorMsg);  
            } else if(show2FAOptions && (twoFAValue == undefined || twoFAValue == '')){
                component.find('maciCustomNotification').showToast ("warning", 'User must select an option for Two-Factor Authentication'); 
            }else{
                component.set("v.ShowSpinner",true);
                helper.verifyUserName(component, event, helper);
            }
        }
    },
    
    setStartUrl: function (component, event, helpler) {
        
        var startUrl = '/s';
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function(component, event, helpler){
       
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            //helpler.handleLogin(component, event, helpler);
            
        }
    },
    
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(cmp, event, helper) {
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl");
        }
    
        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    }, 
   
    getSelectedRole : function(component, event, helper) {
        
        var selectedRole = component.find("role").get("v.value");
        if(selectedRole == 'Prescriber' || selectedRole == 'Pharmacy' || selectedRole == 'Patient'){
            component.set("v.showModal", false);
             component.set("v.selectedRole", selectedRole);
        }
    },
    
    validateCode : function(component, event, helper) {
        component.find('maciCustomNotification').closePreviousModal();
        var vCode = component.get("v.verificationCode");
        var username =   component.get("v.userName")
        var programName = component.get("v.programName");
        
        if(vCode == undefined || vCode == ''){
        	//alert('Please enter verification Code');
            component.find('maciCustomNotification').showToast ("warning", "Please enter verification Code.");  
        }else{
            var action = component.get("c.validateTwoFactorAuthentication");
            action.setParams({username:username, programName:programName, vcode:vCode});
            action.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                
                if(rtnValue == true){
                     helper.handleLogin(component, event, helper);
                }else {
                    //alert('verification code is not matching');
                    component.find('maciCustomNotification').showToast ("warning", "Verification code is not matching.");  
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    togglePassword : function(component, event, helper) {
        var pwdIcon = component.find('pwrdIcon');
        if(component.get("v.showpassword") == true){
            $A.util.removeClass(pwdIcon, 'passwordIconNoColor');
            component.set("v.showpassword",false);
        }else{
            $A.util.addClass(pwdIcon, 'passwordIconNoColor');
            component.set("v.showpassword",true);
        }
    },
    
    handleRoleOnChange : function(component, event, helper) {
        var userName =$("#role").val();
        if(userName != '--None--' && userName != undefined && userName != ''){
                    

            component.set("v.showModal",false);
            component.set("v.ShowSpinner",true);
            helper.validateUserCredentials(component, event, helper,userName);
        }
    },
    
    closePreLaunchModal : function(component, event, helper) {
        component.set('v.showPreLaunchModal', false);
    },
    handleFAChange : function(component, event, helper) {
        if(component.get("v.value2FA") == 'Opt-Out'){
            component.set("v.show2FAOptOut",true);
        } else {
            component.set("v.show2FAOptOut",false);  
        }
        
    },
    
})