import { LightningElement,api } from 'lwc';
import productId from '@salesforce/schema/Product2.Name';
export default class SynProductLookup extends LightningElement {
   
    @api childObjectApiName = 'Case'; 
    @api targetFieldApiName = 'ProductId'; 
    @api fieldLabel = 'Product';
    @api disabled = false;
    @api value;
    @api required = false;

    handleChange(event) {

        // Creates the event
        const selectedEvent = new CustomEvent('valueselected', {
            detail: event.detail.value
            
                        
        });
      
        this.value = event.target.value;
        this.productId = event.target.value;
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
                errorMessage: "Product is required" 
             }; 
        }
    }
}