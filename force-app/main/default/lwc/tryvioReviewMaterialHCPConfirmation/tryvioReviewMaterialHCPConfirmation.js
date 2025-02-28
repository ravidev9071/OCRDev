import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
import { NavigationMixin } from 'lightning/navigation';
export default class TryvioReviewMaterialHCPConfirmation extends NavigationMixin(LightningElement) {  
    iconPrescriber = tryvioIconPrescriber;

    connectedCallback() {
        loadStyle(this, customStyles)
        .then(() => {
            console.log('Styles loaded successfully');
        })
        .catch(error => {
            console.error('Error loading the styles', error);
        });
    
    }

    handleNext(event){
        try {
            event.preventDefault();
            event.stopPropagation();
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'tryvioRemsKAQuestionsReviewMaterialHCP__c'
                }
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }
}