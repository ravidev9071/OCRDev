({
	resendConfirmationMail : function(component, event, helper) {
       var junkMailVerification = $("#flexCheckDefault").is(":checked"); //$("#flexCheckDefault").val();
        if(junkMailVerification == true){
            helper.sendConfirmationEmail(component, event, helper);
        }else{
            helper.showToast(component,event,'Please select the checkbox','warning'); 
        }
	},
    

})