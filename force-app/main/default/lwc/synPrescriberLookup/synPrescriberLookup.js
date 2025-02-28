import { LightningElement, api } from 'lwc';
import accountId from '@salesforce/schema/Account.Name';

export default class SynPrescriberLookup extends LightningElement {

    firstName = '';
    @api childObjectApiName = 'Case'; //Case is the default value
    @api targetFieldApiName = 'SYN_Prescriber__c'; //AccountId is the default value
    @api fieldLabel = 'Prescriber';
    @api disabled = false;
    @api value;
    @api required = false;

    handleChange(event) {

        /*let elemen = this.template.querySelector('lightning-input-field');
        let pres = elemen.value;
        if (pres == '' || pres == null)  {
            elemen.setCustomValidity("Error!");
        } else {
            elemen.setCustomValidity("");
        }
        elemen.reportValidity();*/
        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
            
                        
        });
        this.value = event.target.value;
        this.accountId = event.target.value;
        //dispatching the custom event
        this.dispatchEvent(selectedEvent);

        
        
    }

    @api
    validate () {
        if(this.value) {
            return { isValid: true };
        } else {
            return { 
                isValid: false, 
                errorMessage: "Prescriber value is required" 
             }; 
        }
    }
}