import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconPrescriber from '@salesforce/resourceUrl/tryvioIconPrescriber';
export default class TryvioRemsKAQuestionsMarked2 extends LightningElement {   
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
}