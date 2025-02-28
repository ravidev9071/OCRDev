({
    handleForgotPassword: function (component, event, helpler) {
        component.find('maciCustomNotification').closePreviousModal();
        var username = component.find("username").get("v.value");
		if(username == undefined || username == ''){
           component.find('maciCustomNotification').showToast("warning", "Please enter username.");
        }else{
         	helpler.handleForgotPassword(component, event, helpler);   
        }
    },
    onKeyUp: function(component, event, helpler){
    //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleForgotPassword(component, event, helpler);
        }
    },
    handleCancel: function (component, event, helpler) {
       window.history.back();
    },
    
    handleRoleOnChange : function(component, event, helpler) {
         var userName =$("#role").val();
         if(userName != '--None--' && userName != undefined && userName != ''){
             component.set("v.showModal",false);
             component.set("v.ShowSpinner",true);
             helpler.sendForgotPasswordLink(component, event, helpler,userName);
         }
    },
    
})