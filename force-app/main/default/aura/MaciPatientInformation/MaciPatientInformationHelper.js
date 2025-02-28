({
	 handleInit : function(component, event) {
        var action = component.get("c.getCurrentUserAccountInfo");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();
				var newPhoneNo = this.formatPhoneNumber(component,resultData.Phone);
                if(component.get('v.isOfficeContact')) {
                    this.getprescriberName(component, event);
                }
                component.set('v.phoneNumber', newPhoneNo);
                component.set('v.cAccount', resultData);

                if(!component.get('v.isOfficeContact')) {
                    this.getCurrentPrescriberPatientInfo(component, event);
this.getCurrentPrescriberEnrolledCaseInfo(component, event);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
getCurrentPrescriberEnrolledCaseInfo : function(component, event) {
        var action = component.get("c.getPatientPregnancyEnrolledCase");
        var patientAccount= component.get("v.patientID");
        action.setParams({
            patientId : patientAccount
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                component.set('v.caseEnrolledRecord', resultData);
            }
        });
        $A.enqueueAction(action);
    },
    

    getprescriberName: function(component, event) {
        var action = component.get("c.getCaseRecord");
        action.setParams({
            caseId : component.get("v.caseId")
        });
        action.setCallback(this, function(result) {
            
            if(result.getState() === "SUCCESS") {
                var resultData = result.getReturnValue();
                component.set('v.caseRecord', resultData);
                component.set("v.patientID", component.get("v.caseRecord.US_WSREMS__Patient__c"));
            }
            this.getCurrentPrescriberPatientInfo(component, event);
        });
        $A.enqueueAction(action);
    },

    formatPhoneNumber: function(component, phone) {
        var s2 = (""+phone).replace(/\D/g, '');
        var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
        return (!m) ? null : "(" + m[1] + ") " + m[2] + "-" + m[3];
    },
    getCurrentPrescriberPatientInfo : function(component, event) {

        var action = component.get("c.getPatientPregnancyInfo");
        var patientAccount= component.get("v.patientID");
        
        action.setParams({
            program : 'Macitentan REMS',
            patientId : patientAccount
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            
            if (component.isValid() && state === "SUCCESS"){
                component.set('v.isLoading', false);
                var resultData = result.getReturnValue();
                component.set('v.pAccount', resultData);
            }
            if(component.get('v.pAccount.US_WSREMS__Patient_Risk_Category__c') =='FNRP (other medical reasons for permanent irreversible infertility)' || component.get('v.pAccount.US_WSREMS__Patient_Risk_Category__c') == 'FNRP (Patient is pre-pubertal)' || component.get('v.pAccount.US_WSREMS__Patient_Risk_Category__c') == 'FNRP (Patient is post-menopausal)' || component.get('v.pAccount.US_WSREMS__Status__c') == 'Disenrolled' ) {
                component.set("v.isDisabled" , false);
            } 
        });
        $A.enqueueAction(action);
    },
    
    fetchResources: function(component,event){
        var pname = component.get("v.ProgramName");
        var rtype = component.get("v.RequestorType");
        var recordtypeName = component.get("v.recordTypeDeveloperName");
        var programId = component.get("v.programId");
        var portalrole = component.get("v.portalRole");
        
        var action = component.get("c.getRelatedFilesByRecordId"); 
        action.setParams({
            recordTypeDevName : recordtypeName,
            programId : programId,
            portalRole : portalrole
        });
        action.setCallback(this, function(response) {
            
            let result = response.getReturnValue();
            
           
            
           var filesList =[];
            
             filesList = Object.keys(result).map(item => ({
           
                    "label": result[item].Name,
                    "value": item,
                    "downloadurl": result[item].ContentDownloadUrl,
                    "previewurl": result[item].DistributionPublicUrl,
                 	"contentdocumentId": result[item].ContentDocumentId
                    
                }));
               
            
            component.set("v.resourceList",filesList);
           
        });
        $A.enqueueAction(action);    
    },
  
})