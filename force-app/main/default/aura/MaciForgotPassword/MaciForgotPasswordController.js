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
        //Navigate to Prescriber Page
        var nav = component.find("navigation");
        var pageReference = {
            type: "standard__namedPage",
            attributes: {
                pageName: 'login'
            }
        };
        nav.navigate( pageReference ); 
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