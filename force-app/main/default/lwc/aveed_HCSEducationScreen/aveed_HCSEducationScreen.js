import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_resources';
import aveed_adobeReader from "@salesforce/resourceUrl/aveed_adobeReader";
import { NavigationMixin } from 'lightning/navigation';
import aveed_check from "@salesforce/resourceUrl/aveed_Iconcheck";
import customHomeStyles_secure from '@salesforce/resourceUrl/aveed_customcssSecure';
import getFilesPublicLink from '@salesforce/apex/Aveed_HCSEducationProgramCtrl.getFilesPublicLink';

const PATH_MAP = new Map([[0, ".educationProgram"], [1, ".completeProgram"]]);

export default class Aveed_HCSEducationScreen extends NavigationMixin(LightningElement) {

    @api recordId;
    filesList = [];
    fileTitle = "AVEED REMS Education Program for Healthcare Settings"
    fileName = "AVEED REMS Education Program for Healthcare Settings";
    showNext = false;
    iconCheck = aveed_check;
    iconAdobeReader = aveed_adobeReader;
    currentPath = 0;
    completedPath = 0;
    displaySpinner = false;
    @track fileURL;

    get isDisabled() {
        return !this.showNext;
    }

    get isDisplayFiles() {
        return (this.fileURL != null && this.fileURL.length > 0);
    }

    async connectedCallback() {
        try {
            this.displaySpinner = true;
            loadStyle(this, customHomeStyles);
            loadStyle(this, customHomeStyles_secure);

            const result = await getFilesPublicLink({ 'fileTitle': this.fileName ,'portalRole':'Public' ,'record_type':'Pharmacy'});
            if (result) {
                for (let file in result) {
                    this.fileURL = result[file].DistributionPublicUrl;
                }
            }
            this.displaySpinner = false;
        } catch (error) {
            console.log(error);
            this.displaySpinner = false;
        }
    }

    previewHandler(event) {
        this.showNext = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.fileURL
            }
        }, false);
    }

    handleNext() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Hcs_enrollment__c'
            }
        });
    }

    renderedCallback() {
        setTimeout(() => {
            for (let i = 0; i < this.completedPath; i++) {
                let element = this.template.querySelector(PATH_MAP.get(i));
                this.completePathHandler(element);
            }
        }, 100);
    }

    completePathHandler(element) {
        element.classList.remove('slds-is-current');
        element.classList.add('slds-is-complete');
        element.classList.remove('slds-is-incomplete');
    }

    currentPathHandler(element) {
        element.classList.add('slds-is-current');
        element.classList.remove('slds-is-complete');
        element.classList.add('slds-is-incomplete');
    }
}