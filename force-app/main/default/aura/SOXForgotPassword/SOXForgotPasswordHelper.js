({
    handleForgotPassword: function (component, event, helpler) {
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var programName = component.get("v.programName");
        var action = component.get("c.getUserName");
         //Console.log('--action--'+action);
         console.log('--username11--'+username);
         console.log('--programName11--'+programName);
        action.setParams({username:username, programName:programName});
        action.setCallback(this, function(a) {
            
         console.log('--programName--'+programName);
          //this.sendForgotPasswordLink(component, event, helpler,username); 
            console.log('functiona'+a);
            console.log('functiona'+a.getState());
            var result = a.getReturnValue();
            console.log('insidehandleForgotPassword'+JSON.stringify(result));
            console.log('--usernameaaaaaa--'+result[programName]);
            console.log('--usernameaaaaaa22--'+result.programName);
            var userNameMap = [];
            var userName;
                for(var key in result){
                    userNameMap.push({key: key, value: result[key]});
                   	userName =  result[key];
                } 
            component.set("v.userRolesMap", userNameMap);
            console.log('userMapdata'+userNameMap);
            if(userNameMap.length == 1){
                component.set("v.ShowSpinner",true);
            	this.sendForgotPasswordLink(component, event, helpler,userName);
            }else if(userNameMap.length > 1){
            	component.set("v.showModal",true);
            }else{
                this.LightningAlert.open({
                    message: 'An account with this information does not exist. Please try again or contact the Sodium Oxybate REMS for assistance.',
                    theme: 'Error',
                    label: 'Error!',
                }).then(function() {
                    console.log('alert is closed');
                });
          // alert('Sorry, We do not have user with provided email address, Please contact Sodium Oxybate REMS Support Team.');
            }
       });
        $A.enqueueAction(action);
    },
    
    sendForgotPasswordLink: function (component, event, helpler,username) {
        //var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var action = component.get("c.forgotPassowrd");
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            component.set("v.ShowSpinner",false);
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }
       });
        $A.enqueueAction(action);
    }
})