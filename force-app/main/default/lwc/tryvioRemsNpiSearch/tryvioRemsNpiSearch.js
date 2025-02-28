import { LightningElement, api } from 'lwc';
import getExistingAccJS from '@salesforce/apex/TryvioEnrollmentCls.getExistingAccount';
import getNPIStatusVeeva from '@salesforce/apex/TryvioEnrollmentCls.getNPISearch';
import tryvioProgramName from '@salesforce/label/c.Tryvio_REMS_Program_Name';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import customHomeStyles from '@salesforce/resourceUrl/tryvioremsCss';
import inValidNPI from '@salesforce/label/c.tryvio_Invalid_NPI';
//Phone and fax formatng 
export default class TryvioRemsNpiSearch extends LightningElement {
    npiRecord ={};
    @api programName = tryvioProgramName;
    @api participantType;
    @api accRecordTypeDevName;
    @api npiLabel ='NPI';
    @api npiPlaceholder = '';
    @api caseRecordTypeDevName;
    disabled = false;
    displayInvalidNpi = false;
    displaySpinner = false;
    invalidMsg = inValidNPI;
    
    connectedCallback() {
        loadStyle(this, customHomeStyles);     
        console.log('in child');
    }

    searchKeyword(event) {
        this.displaySpinner = true;
        this.searchValue = event.target.value;
        this.valid = true;
        let field1 = this.template.querySelector('.search');
        this.displayInvalidNpi = false;
        if (this.searchValue && (this.searchValue.length > 10 || !(/^\d+$/.test(this.searchValue)))) {
            console.log('True inside displayInvalidNpi::');
            this.displayInvalidNpi = true;
            console.log('True displayInvalidNpi::', this.displayInvalidNpi);
        } else {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();
        }
        this.displaySpinner = false;
        console.log('True if displayInvalidNpi::', this.displayInvalidNpi);
    }

    async handleSearchKeyword() { 
        this.displaySpinner = true;
        this.showDetails = false;
        this.errorFields = [];
        console.log('consle displayInvalidNpi::', this.displayInvalidNpi)
        if(this.displayInvalidNpi) {
            console.log('displayInvalidNpi::');
            this.showToast('Error', 'Please enter valid NPI', 'error');
            this.displaySpinner = false;
            return;
        }
        this.npiRecord = {};
        let field1 = this.template.querySelector('.search');
        this.valid = true;
        field1.validity = { valid: true };
        field1.setCustomValidity('');
        field1.reportValidity();
        if (this.searchValue === undefined || (this.searchValue !== undefined && this.searchValue.length === 0)) {
            this.valid = false;
            field1.validity = { valid: false };
            field1.setCustomValidity('Please enter NPI to search.');
            field1.focus();
            field1.blur();
            field1.reportValidity();
        } else if (this.valid) {
            this.valid = true;
            field1.validity = { valid: true };
            field1.setCustomValidity('');
            field1.reportValidity();
            try {
                let isVeevaAPIHappen = false;
                let result;
                let accountId;
                let accountStatus;
                let veevaStatus;
                let accountRecordTypeName;
                let accountRecordTypeNameList = ['Outpatient_Pharmacy_Account', 'Inpatient_Pharmacy_Account'];
                let isEnrollmentCaseAvailable = false;
                const EXISTING_ACCOUNT = await getExistingAccJS({programName : this.programName, npiKey : this.searchValue, accRecTypeDevNameList : accountRecordTypeNameList});
                console.log('EXISTING_ACCOUNT::::'+JSON.stringify(EXISTING_ACCOUNT));
                if(EXISTING_ACCOUNT != null && EXISTING_ACCOUNT.length > 0 ) {
                    accountStatus = EXISTING_ACCOUNT[0].US_WSREMS__Status__c;
                    accountId = EXISTING_ACCOUNT[0].Id;
                    accountRecordTypeName = EXISTING_ACCOUNT[0].RecordType.DeveloperName;
                    if(EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Certified' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Certified - On Hold' 
                        || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Pending' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Decertified' || EXISTING_ACCOUNT[0].US_WSREMS__Status__c == 'Deactivated') {
                        isVeevaAPIHappen = false;
                        this.disabled = false;
                    } else {
                        isVeevaAPIHappen = true;
                    }
                } else {
                    isVeevaAPIHappen = true;
                }
                
                if(isVeevaAPIHappen) {
                    const NPI_RESPONSE = await getNPIStatusVeeva({ searchNPIKey: this.searchValue,programName : this.programName, caseRecordTypeDevName : this.caseRecordTypeDevName });
                    console.log('NPI_RESPONSE=>', NPI_RESPONSE);
                    switch(NPI_RESPONSE){
                        case 'Failed':
                            veevaStatus = 'Failed';
                            break;    
                        default:
                            result = JSON.parse(NPI_RESPONSE);
                            result.npi = this.searchValue;
                            this.disabled = true;
                    }   
                }
                if(veevaStatus == 'Failed') { 
                    console.log('veevaStatus::', veevaStatus);
                    this.disabled = false;
                    this.valid = false;
                    field1.validity = { valid: false };
                    field1.setCustomValidity(this.invalidMsg);
                    field1.focus();
                    field1.blur();
                    field1.reportValidity();
                    this.displaySpinner = false;
                    return;
                } else {
                    const selectedEvent = new CustomEvent("continue", {
                        detail: {
                            accountStatus : accountStatus,
                            accountId : accountId,
                            veevaStatus : veevaStatus,
                            isEnrollmentCaseAvailable : isEnrollmentCaseAvailable,
                            accountRecordTypeName : accountRecordTypeName,
                            response : result
                        }
                    });
                    this.dispatchEvent(selectedEvent);
                }
            } catch(e) {
                console.log('e->', e);
                this.showToast('Error', e.message, 'error');
            }
        }
        this.displaySpinner = false;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}