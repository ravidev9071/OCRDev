import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customStyles from '@salesforce/resourceUrl/tryvioremsCss';
import tryvioIconRDA from '@salesforce/resourceUrl/tryvioIconRDA';
import tryvioIconSortAsc from '@salesforce/resourceUrl/tryvioIconSortAsc';
import {NavigationMixin} from 'lightning/navigation';
import searchAccountsByNpi from '@salesforce/apex/AccountControllerRDA.searchAccountsByNpi';
import searchAccountsByName from '@salesforce/apex/AccountControllerRDA.searchAccountsByName';
import createCase from '@salesforce/apex/AccountControllerRDA.createCase';
import createCaseWithoutAccount from '@salesforce/apex/AccountControllerRDA.createCaseWithoutAccount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPickListValues from '@salesforce/apex/AccountControllerRDA.getPicklistFieldValues';

export default class TryvioRemsVerification extends NavigationMixin(LightningElement) {
    iconRDA = tryvioIconRDA;
    iconSortAsc = tryvioIconSortAsc;
    isName=false;
    isNPI=true;
    showTable = false;
    spinner = false;
    @track npi = '';
    @track firstname = '';
    @track lastname = '';
    @track state = '';
    @track accounts;
    @track selectedAccountId;
    @track isNpiSearch = true;
    @track isNameSearch = false;
    stateOptions = [];

    
    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'npi') {
            this.npi = event.target.value;
            this.isNpiSearch = true;
        } else if (field === 'firstname') {
            this.firstname = event.target.value;
        } else if (field === 'lastname') {
            this.lastname = event.target.value;
            this.isNameSearch = true;
        }  else if (field === 'state') {
            console.log('state:::', event.target.value);
            this.state = event.target.value;
            
            this.isNameSearch = true;
        }
        if((this.isNpiSearch && this.npi == '') || (this.isNameSearch && this.firstname == '' && this.lastname == '' && this.state == '') ) {
            this.accounts = '';
            this.selectedAccountId = '';
        }
    }

    handleSearch() {
        this.showTable = true;
        this.accounts = '';
        if (this.isNpiSearch) {
            if ((!this.npi || this.npi.length === 0 || (this.npi && (this.npi.length > 10 || !(/^\d+$/.test(this.npi)))))) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter valid NPI',
                        variant: 'error',
                    })
                );
            } else {
                searchAccountsByNpi({ npi: this.npi })
                    .then(result => {
                        this.accounts = result;
                        if (this.accounts.length === 0) {
                            this.spinner = true;
                            this.accounts = '';
                            createCaseWithoutAccount({firstname: this.firstname, lastname: this.lastname, state: this.state, npi : this.npi})                            .then(result => {
                                this.navigateToCasePage(result);
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: error.body.message,
                                        variant: 'error',
                                    })
                                );
                            });
                        }
                    })
                    .catch(error => {
                        console.log('Inside catch(error =>');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    });
            }
        } 
        if (this.isNameSearch) {
            if (this.isNameSearch && (this.lastname.length > 0 && this.state.length > 0)) {
                searchAccountsByName({ firstname: this.firstname, lastname: this.lastname, state: this.state })
                    .then(result => {
                        this.accounts = result;
                        if (this.accounts.length === 0) {
                            this.spinner = true;
                            this.accounts = '';
                            createCaseWithoutAccount({firstname: this.firstname, lastname: this.lastname, state: this.state})
                            .then(result => {
                                this.navigateToCasePage(result);
                            })
                            .catch(error => {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: error.body.message,
                                        variant: 'error',
                                    })
                                );
                            });
                        }
                    })
                    .catch(error => {
                        console.log('Inside catch(error => {');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: error.body.message,
                                variant: 'error',
                            })
                        );
                    });
            } else if (this.isNameSearch && (this.lastname.length=== 0 && this.state.length=== 0)) {
                this.dispatchEvent( new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Please enter valid Name and State',
                                    variant: 'error', })
                                    );
            } else if (this.isNameSearch && (this.lastname.length=== 0)) {
                this.dispatchEvent( new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Please enter valid Name',
                                    variant: 'error', })
                                    );
            } else if (this.isNameSearch && (this.state.length=== 0)) {
                this.dispatchEvent( new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Please enter valid State',
                                    variant: 'error', })
                                    );
            }
        }
    }
    handleRowSelection(event) {
        console.log('enter::');
        console.log('event.target.value::', event.currentTarget.dataset.id);
        this.selectedAccountId = '';
        let inputFields = this.template.querySelectorAll('input[data-cmp="check1"]');
        console.log('inputFields', inputFields.length);
        inputFields.forEach(inputField => {
            inputField.checked = false;
            if(inputField.dataset.id == event.currentTarget.dataset.id) {
                console.log('inside::', inputField.dataset.id);
                inputField.checked = true;
                this.selectedAccountId = inputField.dataset.id;
            }
        });
    }

    handleContinue() {
        this.spinner = true;
        createCase({ accountId: this.selectedAccountId })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Case created successfully.',
                        variant: 'success',
                    })
                );
                this.navigateToCasePage(result);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    navigateToCasePage(caseId) {

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Rems_Verification_Success__c',
            },
            state: {
                caseId: caseId
            }
        });
    }

    connectedCallback() {
        loadStyle(this, customStyles);
        this.getPickListValues();
    }
    handleChangeRadio(event) {
        console.log('**handleChangeRadio* '+event.target.value);
        this.isName = false;
        this.isNPI = false;
        this.showTable = false;
        if(event.target.value == 'name'){
            this.isName = true;
            this.isNameSearch = true;
            this.isNpiSearch = false;
        }
        else if(event.target.value == 'npi'){
            this.isNPI = true; 
            this.isNameSearch = false;
            this.isNpiSearch = true;
        }
    }
    getPickListValues() {
        getPickListValues()
            .then((pickListVal) => {
                console.log('returndata >>', pickListVal);
                console.log(pickListVal.US_WSREMS__State__c);
                var stateOptionList = pickListVal.US_WSREMS__State__c;
                for (var i in stateOptionList) {
                    if(stateOptionList[i] != 'AA' && stateOptionList[i] != 'AE' && stateOptionList[i] != 'AP') {
                        const option = {
                            label: i,
                            value: stateOptionList[i]
                        };
                        this.stateOptions = [...this.stateOptions, option];
                    }
                }
                console.log('this.stateOptions=>', this.stateOptions);
            })
            .catch((error) => {
                console.log('Error is', error);
            });
    }
}