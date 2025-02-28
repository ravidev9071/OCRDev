({
	doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.handleInit(component, event);
        helper.fetchResources(component,event);
    },
    
    refreshtable: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    //Flow Status Change
    statusChange : function (component, event, helper) {
        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "message",
                type: "success"
            });
            toastEvent.fire();
            component.set("v.isModalOpen", false);
            $A.get('e.force:refreshView').fire();
        } else if (event.getParam('status') === "ERROR") {
            component.set("v.hasError", true);
        }
    },
     
    handleOpenFlow: function(component, event, helper) {
        var selectedOfficeContact = event.currentTarget.getAttribute("data-recordid");
        // Set isModalOpen true
        component.set("v.isModalOpen", true);
         
        //Find lightning flow from component
        var flow = component.find("EditOfficeContactFlow");
        //Put input variable values
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : selectedOfficeContact
            },
        ];
        //Reference flow's Unique Name
        flow.startFlow("Edit_Office_Contact",inputVariables);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    }, 

    openAddOfficeModal : function(component, event, helper) {
        //Dynamic creation of lightningModalChild component and appending its markup in a div
		$A.createComponent( 'c:AddOfficeContact', {
                'headerText' : 'Add Office Contact'
            },
            function(modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    var body = component.find( 'showChildModal' ).get("v.body");
                    body.push(modalComponent);
                    component.find( 'showChildModal' ).set("v.body", body);
                } else if (status === "INCOMPLETE") {
                	console.log('Server issue or client is offline.');
                } else if (status === "ERROR") {
                	console.log('error');
                }
            }
        );
	}
})