import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/aveed_customcss';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
const PATH_MAP = new Map([[0, ".educationProgram"], [1, ".knowledgeProgram"], [2, ".completeProgram"]]);

export default class Aveed_KA_Success extends NavigationMixin(LightningElement) {

    currentPath = 1;
    completedPath = 2;

    connectedCallback() {
        loadStyle(this, customHomeStyles);
    }

    navigatetoEnrollment(event) {
        console.log('enrollment');
        try {
            console.log('enrollment1');

            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'hcp_enrollmnet__c'
                }
            }).then(() => {
                window.location.reload();
            });
        } catch (error) {
            console.log('error --' + error.message);
        }
    }

    renderedCallback() {
        setTimeout(() => {
            let currentElement = this.template.querySelector(PATH_MAP.get(this.currentPath));
            this.currentPathHandler(currentElement);
            for (let i = 0; i < this.completedPath; i++) {
                let element = this.template.querySelector(PATH_MAP.get(i));
                this.completePathHandler(element);
            }

        }, 100)
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