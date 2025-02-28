({
   handleNext: function(component, event, helper) {
        var alphapattern = /^[a-z]+$/;
        var numericpattern = /^[0-9]+$/;
        var specialcharacterpattern= new RegExp('^.*[-!@#$%^&*()_+|~=`{}[\\]:";\'<>?,.\/]+.*$');
        var password = component.get("v.password");
        var confrmpassword = component.get("v.confirmPassword");
        
       var lowerCaseLetters = /[a-z]/g;
       var numbers = /[0-9]/g;

        var twofactorFlag = $("#flexCheckDefault").is(":checked"); 
        var username = component.get("v.oPharmyInfo.US_WSREMS__Email__c");
		
		
        if(username == undefined || username == ''){
             helper.showToast(component,event,'Please enter username.','Warning');
        }else if(password == undefined || password == ''){
            helper.showToast(component,event,'Please enter password.','Warning');
        }else if(password.length < 8){
            helper.showToast(component,event,'Minimum password length is 8','Warning');
        }else if(password.length > 12){
            helper.showToast(component,event,'Password length be between 8 and 12 characters','Warning');
        }else if(confrmpassword == undefined || confrmpassword == ''){
            helper.showToast(component,event,'Please Re-enter password','Warning');
        }else if(password != confrmpassword){
            helper.showToast(component,event,'Password and Confirm password are not matching','Warning');
        }else if(password != undefined && (!password.match(lowerCaseLetters) || !password.match(numbers))){
            helper.showToast(component,event,'Password must include alpha and numeric characters','Warning');
        }else if(component.get("v.value2FA") == undefined || component.get("v.value2FA") == null){
            helper.showToast(component,event,'Two Factor Authentication (2FA) selection is required to proceed','Warning');
        }else{
            component.set("v.ShowSpinner",true);
            helper.handleNextButton(component,event,helper);
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
    
    showTwoFactorMessage : function(component, event, helper) {
        component.set("v.showTwoFactorAuth",true);
    },
    
    hideTwoFactorMessage : function(component, event, helper) {
        component.set("v.showTwoFactorAuth",false);
    },
    handleFAChange : function(component, event, helper) {
        if(component.get("v.value2FA") == 'Opt-Out'){
            component.set("v.show2FAOptOut",true);
        } else {
            component.set("v.show2FAOptOut",false);  
        }
        component.set("v.show2FAError",false);
        
    },
})