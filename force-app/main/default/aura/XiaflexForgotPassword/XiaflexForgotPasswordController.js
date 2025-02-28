({
    handleForgotPassword: function (component, event, helpler) {
        component.find('maciCustomNotification').closePreviousModal();
        var username = component.find("username").get("v.value");
        var persona = component.get("v.value");
		if(!username ){
           component.find('maciCustomNotification').showToast("warning", "Please enter email address.");
        }else if(!persona){
           component.find('maciCustomNotification').showToast("warning", "Please Select Person Type");
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
		var ProgramType = component.get("v.ProgramType");
        var currentUrl;
        var loginUrl = component.get("v.LoginUrl");
  		currentUrl = window.location.href;
        var homeUrl = currentUrl.substring(0, currentUrl.indexOf('s/'))+loginUrl;    
        window.location.href = homeUrl;
    },
    
    handleRoleOnChange : function(component, event, helpler) {
          var userName = event.getSource().get("v.value");
         if(userName != '--None--' && userName != undefined && userName != ''){
             component.set("v.showModal",false);
             component.set("v.ShowSpinner",true);
             helpler.sendForgotPasswordLink(component, event, helpler,userName);
         }
    },
    
})