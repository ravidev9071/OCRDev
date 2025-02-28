({
	closeModal : function(component, event, helper) {
		// when a component is dynamically created in lightning, we use destroy() method to destroy it.
		component.destroy();
	},
 
	// action to execute when save button is clicked
	handleSave : function(component, event, helper) {
		// We are showing an alert box here, you can perform any stuff here.
		component.destroy();
	},

	handleInputChange: function(component, event, helper) {
        helper.validateFields(component);
    },

    handleSearch: function(component, event, helper) {
        helper.searchAccounts(component);
    },
	handleNewSearch: function(component, event, helper) {
         helper.handleNewSearchHelper(component);
    },
    handleContactSubmit: function(component, event, helper) {
        helper.handleContactSubmitHelper(component);
    },
    
    handleAffiliationSubmit : function(component, event, helper) {
        helper.handleAffiliationSubmitHelper(component);
    },
})