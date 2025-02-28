import { LightningElement,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/xiaflexMDP_customcss'
// import navStyles from '@salesforce/resourceUrl/xiaflexMDP_navcss';
import { NavigationMixin } from 'lightning/navigation';
 
export default class XiaflexMdpLogin extends NavigationMixin(LightningElement) {
    @track value = '';
    @track ConfirmHCP = false
    @track ConfirmHCS= false
    // Define the options for the radio group
    get options() {
        return [
            { label: ' Prescribing Healthcare Provider', value: 'Prescribing Healthcare Provider' },
            { label: ' Pharmacy/Healthcare Setting Authorized Representative', value: 'Pharmacy/Healthcare Setting Authorized Representative' }
        ];
    }

    // Handle value changes
    handleValueChange(event) {
        this.value = event.detail.value;
    }
    connectedCallback(){
        loadStyle(this, customHomeStyles); 
        // loadStyle(this,navStyles);
    }
    handleChange(event) {
        if(event.detail.value == 'Prescribing Healthcare Provider'){
            this.ConfirmHCP = true
            this.ConfirmHCS = false
        }else{
            this.ConfirmHCP = false
            this.ConfirmHCS = true  
        }
        console.log('Selected value: ' + this.value); 
    }

    handleConfirm(){
        if(this.ConfirmHCP){
            this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'HCP_Enrollment_Form__c'
                            }
                        });
        } else if(this.ConfirmHCS){
            this[NavigationMixin.Navigate]({
                            type: 'comm__namedPage',
                            attributes: {
                                name: 'Pharm_hcs_enrollment_form__c'
                            }
                        });
        }
    }

}