import { LightningElement, api } from 'lwc';

export default class PatientLookupForFlow extends LightningElement {

    firstName = '';
    @api objectName;
    @api targetFieldApiName;
    @api displayFieldLabelOne;
    @api displayFieldOne;
    //@api childObjectApiName = 'Case'; //Case is the default value
    @api childObjectApiName; //Case is the default value
    //@api targetFieldApiName = 'US_WSREMS__Patient__c'; //AccountId is the default value
    
    //@api fieldLabel = 'Patient associated with Risk Management Report';
    @api fieldLabel;
    @api disabled = false;
    @api value;
    @api required = false;

    handleChange(event) {const selectedEvent = new CustomEvent('valueselected', {
        detail: event.detail.value
        
                    
    });
    this.value = event.target.value;
    this.accountId = event.target.value;
    //dispatching the custom event
    this.dispatchEvent(selectedEvent);  
    
    }
    /*
    @api
    validate () {
        if(this.value) {
            return { isValid: true };
        } else {
            return { 
                isValid: false, 
                errorMessage: "Patient value is required" 
             }; 
        }
    }*/
}