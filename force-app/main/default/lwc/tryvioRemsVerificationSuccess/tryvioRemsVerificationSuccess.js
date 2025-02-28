import { LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCaseDetails from '@salesforce/apex/AccountControllerRDA.getCaseDetails';


import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconRDA from '@salesforce/resourceUrl/tryvioIconRDA';
import tryvioIconCheck from '@salesforce/resourceUrl/tryvioIconCheck';
import tryvioIconCopyToClipboard from '@salesforce/resourceUrl/tryvioIconCopyToClipboard';
import Phone from '@salesforce/label/c.tryvioPhone';
import Fax from '@salesforce/label/c.tryvioFax';
export default class TryvioRemsVerificationSuccess extends LightningElement {
    iconRDA = tryvioIconRDA;
    iconCheck = tryvioIconCheck;
    iconCopyToClipboard = tryvioIconCopyToClipboard;
    phone = Phone;
    fax = Fax;
    connectedCallback() {
        loadStyle(this, customStyles);
    }

    caseId;
    @track caseDetails;
    @track RDAAuthorizationCode;
    @track npi;
    @track remsId;
    @track firstname;
    @track lastname;
    @track name;
    @track remsstatus;		
    @track certified;		
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.caseId = currentPageReference.state.caseId;
            this.fetchCaseDetails();
        }
    }

    handleCopyClipboard(event) {
        console.log('inside copy clipboard:::');
        let paraDoc = this.template.querySelector('input[data-id="RDAInput"]');
        console.log('inner::', paraDoc.innerHTML)
        paraDoc.disabled = false;
        paraDoc.select();
        document.execCommand('copy');
        paraDoc.disabled = true;
    }

    async fetchCaseDetails() {
        await getCaseDetails({ caseId: this.caseId })
            .then(result => {
                this.RDAAuthorizationCode = result.RDA_Authorization_Code__c;
                if(result.US_WSREMS__Participant__c != null && result.US_WSREMS__Participant__c != undefined) {
                    this.npi = result.US_WSREMS__Prescriber_NPI__c;
                    this.remsId = result.US_WSREMS__Participant__r.US_WSREMS__REMS_ID__c;
                    this.firstname = result.US_WSREMS__Prescriber_First_Name__c ;
                    this.lastname = result.US_WSREMS__Prescriber_Last_Name__c;
                    this.name = result.US_WSREMS__Prescriber_First_Name__c + result.US_WSREMS__Prescriber_Middle_Name__c + result.US_WSREMS__Prescriber_Last_Name__c;
                    this.remsstatus = result.Prescriber_NPI_or_DEA__c;		
                    this.caseDetails = result;
                    if (this.remsstatus ==='Certified') {
                        this.certified = true;
                    } else {
                        this.certified = false;
                    }
                } else {
                    this.certified = false;
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error fetching case details',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    } 
}